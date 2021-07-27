require "../spec_helper"

Spectator.describe TLParser::Type do
  describe "#parse" do
    it "raises ParseError on empty type" do
      expect { described_class.parse("") }.to raise_error(TLParser::ParseError::Empty)
    end

    it "parses a simple, namespaceless type" do
      expect(described_class.parse("foo")).to eq(described_class.new(
        namespace: [] of String,
        name: "foo",
        bare: true,
        generic_ref: false,
        generic_arg: nil,
      ))
    end

    it "raises error on empty namespace" do
      expect { described_class.parse(".") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse("..") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse(".foo") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse("foo.") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse("foo..foo") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse(".foo.") }.to raise_error(TLParser::ParseError::Empty)
    end

    it "parses a correctly namespaced type" do
      expect(described_class.parse("foo.bar.baz")).to eq(described_class.new(
        namespace: ["foo", "bar"],
        name: "baz",
        bare: true,
        generic_ref: false,
        generic_arg: nil,
      ))
    end

    it "parses bare types" do
      expect(described_class.parse("foo").bare).to be_true
      expect(described_class.parse("Foo").bare).to be_false
      expect(described_class.parse("Foo.bar").bare).to be_true
      expect(described_class.parse("Foo.Bar").bare).to be_false
      expect(described_class.parse("foo.Bar").bare).to be_false
      expect(described_class.parse("!bar").bare).to be_true
      expect(described_class.parse("!foo.Bar").bare).to be_false
    end

    it "parses generic refs" do
      expect(described_class.parse("f").generic_ref).to be_false
      expect(described_class.parse("!f").generic_ref).to be_true
      expect(described_class.parse("!Foo").generic_ref).to be_true
      expect(described_class.parse("!X").generic_ref).to be_true
    end

    it "parses generic args" do
      expect(described_class.parse("foo.bar").generic_arg).to be_nil
      expect(described_class.parse("foo<bar>").generic_arg).to_not be_nil
      expect(described_class.parse("foo<bar.Baz>").generic_arg).to_not be_nil
      expect(described_class.parse("foo<!bar.Baz>").generic_arg).to_not be_nil
      expect(described_class.parse("foo<bar<Baz>>").generic_arg).to_not be_nil
    end
  end
end
