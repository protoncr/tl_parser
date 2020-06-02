require "colorize"
require "./tl/*"

module TLParser
  class Iter
    include Enumerable(Tuple(TLParser::Category, TLParser::Definition))

    DEFINITIONS_SEP = ";"
    FUNCTIONS_SEP = "---functions---"
    TYPES_SEP = "---types---"

    def initialize(@data : String)
    end

    def each(&block)
      category = Category::Types
      comment_stack = [] of String

      @data.lines.each_with_index do |line, i|
        if line.includes?(FUNCTIONS_SEP)
          category = Category::Functions
        elsif line.includes?(TYPES_SEP)
          category = Category::Types
        elsif line.lstrip.starts_with?("//")
          comment_stack << line.lstrip.lstrip("//")
          next
        elsif line.lstrip.empty?
          comment_stack.clear
          next
        else
          begin
            definition = Definition.parse(line)
            definition.description = comment_stack.join('\n')
            yield({category, definition})
          rescue err : ParseError
            STDERR.puts "Parse error: failed to parse definition on line #{i + 1}".colorize(:red)
            STDERR.puts "  #{i + 1} | #{line}".colorize(:light_red)
          ensure
            comment_stack.clear
          end
        end
      end
    end
  end
end
