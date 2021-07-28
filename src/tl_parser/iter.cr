require "colorize"
require "./tl/*"

module TLParser
  class Iter
    include Iterator(TLParser::Definition)

    DEFINITIONS_SEP = ";"
    FUNCTIONS_SEP = "---functions---"
    TYPES_SEP = "---types---"

    getter current_category : Category
    getter comment_stack : Array(String)

    private getter stack : Array(String)

    def initialize(data : String)
      @stack = data.lines
      @current_category = Category::Types
      @comment_stack = [] of String
    end

    def next
      return stop if @stack.empty?
      parse_next
    end

    def to_a!
      arr = [] of TLParser::Definition
      loop do
        begin
          value = self.next
          break if value.is_a?(Iterator::Stop)
          arr << value
        rescue
        end
      end
      arr
    end

    private def parse_next
      def_stack = [] of String
      while !@stack.empty?
        line = @stack.shift
        if line.includes?(FUNCTIONS_SEP)
          @current_category = Category::Functions
        elsif line.includes?(TYPES_SEP)
          @current_category = Category::Types
        elsif line.lstrip.starts_with?("//")
          @comment_stack << line.lstrip.lstrip("//")
        elsif line.lstrip.empty?
          @comment_stack.clear
        elsif line.rstrip.ends_with?(";")
          def_stack << line
          definition = Definition.parse(def_stack.join(' '))
          definition.category = @current_category
          definition.description = @comment_stack.join('\n')
          return definition
        else
          def_stack << line
        end
      end

      if !def_stack.empty?
        raise "Unexpected end of input"
      else
        return stop
      end
    ensure
      @comment_stack.clear
    end
  end
end
