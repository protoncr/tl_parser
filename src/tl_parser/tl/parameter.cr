module TLParser
  class Parameter
    # The name of the parameter.
    property name : String

    # The type of the parameter.
    property type : ParamType

    def initialize(@name, @type)
    end

    def self.parse(str : String)
      # special case: parse `{X:Type}`
      if str.starts_with?('{')
        if str.ends_with?(":Type}")
          raise ParseError::TypeDef.new(str[1..(str.index(':').not_nil! - 1)])
        else
          raise ParseError::MissingDef.new
        end
      end

      # parse `name:type`
      begin
        name, ty = str.split(':', 2)
        raise ParseError::Empty.new if name.empty? || ty.empty?
      rescue err : IndexError
        raise ParseError::NotImplemented.new
      end

      Parameter.new(name, ParamType.parse(ty))
    end

    def to_s(io)
      io << "#{name}:#{type}"
    end

    def ==(other)
      other.is_a?(Parameter) &&
      other.name == name &&
      other.type == type
    end
  end
end
