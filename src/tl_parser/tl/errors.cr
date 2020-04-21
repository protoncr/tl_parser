module TLParser
  class ParseError < Exception
    class Empty < ParseError; end

    class MissingType < ParseError; end

    class MissingName < ParseError; end

    class MissingDef < ParseError; end

    class NotImplemented < ParseError; end

    class InvalidID < ParseError; end

    class InvalidParam < ParseError; end

    class InvalidGeneric < ParseError; end

    class InvalidFlag < ParseError; end

    class TypeDef < ParseError
      property name : String
      def initialize(@name)
        super("{name: #{@name}}")
      end
    end
  end
end
