module TLParser
  abstract struct ParamType
    def self.parse(str : String)
      str = str.strip
      raise ParseError::Empty.new if str.empty?

      # parse `#`
      if str == "#"
        return FlagsParam.new
      end

      # parse `flag_name.flag_index?type`
      ty, flag = if (pos = str.index('?'))
        {str[(pos + 1)..], Flag.parse(str[...pos])}
      else
        {str, nil}
      end

      # parse `type<generic_arg>`
      ty = Type.parse(ty)

      NormalParam.new(ty, flag)
    end
  end

  struct FlagsParam < ParamType
    def to_s(io)
      io << "#"
    end

    def ==(other)
      other.is_a?(FlagsParam)
    end
  end

  struct NormalParam < ParamType
    getter type : Type
    getter flag : Flag?

    def initialize(@type, @flag = nil)
    end

    def to_s(io)
      if flag
        io << "#{flag}?"
      end
      io << type
    end

    def ==(other)
      other.is_a?(NormalParam) &&
      other.type == type &&
      other.flag == flag
    end
  end
end
