module TLParser
  # Data attached to parameters conditional on flags.
  record Flag,
      # The name of the parameter containing the flags in its bits.
      name : String,

      # The bit index used by this flag inside the flags parameter.
      index : UInt32 do

    def self.parse(str : String)
      if str.includes?('.')
        pieces = str.split('.')
        name = pieces.first(pieces.size - 1).join('.')
        index = begin
          pieces.last.to_u32
        rescue err : ArgumentError
          raise ParseError::InvalidFlag.new
        end
        Flag.new(name, index)
      else
        raise ParseError::InvalidFlag.new
      end
    end

    def to_s(io)
      io << "#{name}.#{index}"
    end

    def ==(other)
      other.is_a?(Flag) &&
      other.name == name &&
      other.index == index
    end
  end
end
