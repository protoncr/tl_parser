require "digest/crc32"

module TLParser
  module Utils
    def self.infer_id(definition : String) : UInt32
      rep = definition
        .gsub(":bytes", ": string")
        .gsub("?bytes", "? string")
        .gsub("<", " ")
        .gsub(">", "")
        .gsub("{", "")
        .gsub("}", "")
        .gsub(/ \w+:flags\.\d+\?true/, "")

      Digest::CRC32.checksum(rep)
    end
  end
end
