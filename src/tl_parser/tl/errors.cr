module TLParser
  class ParseError < Exception
    class Empty < ParseError; end

    class MissingType < ParseError; end

    class MissingName < ParseError; end

    class MissingDef < ParseError; end

    class NotImplemented < ParseError; end

    class InvalidID < ParseError
      property id : String
      def initialize(@id)
        super("{id: #{@id}}")
      end
    end

    class InvalidParam < ParseError
      property sub_error : ParseError.class
      def initialize(@sub_error)
        super("{sub_error: #{@sub_error}}")
      end
    end

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
