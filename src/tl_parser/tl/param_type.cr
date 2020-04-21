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
  end

  struct NormalParam < ParamType
    getter type : Type
    getter flag : Flag?

    def initialize(@type, @flag = nil)
    end
  end
end
