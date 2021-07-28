require "./tl_parser/**"

module TLParser
  def self.parse(contents : String)
    stack = TLParser::Iter.new(contents).to_a!
  end

  def self.parse(contents : String, &block)
    TLParser::Iter.new(contents).each { |d| block.call(d) }
  end
end
