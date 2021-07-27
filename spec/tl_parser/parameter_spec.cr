require "../spec_helper"

Spectator.describe TLParser::Parameter do
  describe "#parse" do
    it "raises ParseError on empty type" do
      expect { described_class.parse(":noname") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse("notype:") }.to raise_error(TLParser::ParseError::Empty)
      expect { described_class.parse(":") }.to raise_error(TLParser::ParseError::Empty)
    end

    it "raises ParseError on unknown param" do
      expect { described_class.parse("") }.to raise_error(TLParser::ParseError::NotImplemented)
      expect { described_class.parse("no colon") }.to raise_error(TLParser::ParseError::NotImplemented)
      expect { described_class.parse("colonless") }.to raise_error(TLParser::ParseError::NotImplemented)
    end

    it "raises ParseError on bad flags" do
      expect { described_class.parse("foo:bar?") }.to raise_error(TLParser::ParseError::InvalidFlag)
      expect { described_class.parse("foo:?bar") }.to raise_error(TLParser::ParseError::InvalidFlag)
      expect { described_class.parse("foo:bar?baz") }.to raise_error(TLParser::ParseError::InvalidFlag)
      expect { described_class.parse("foo:bar.baz?qux") }.to raise_error(TLParser::ParseError::InvalidFlag)
    end

    it "raises ParseError on bad generics" do
      expect { described_class.parse("foo:<bar") }.to raise_error(TLParser::ParseError::InvalidGeneric)
      expect { described_class.parse("foo:bar<") }.to raise_error(TLParser::ParseError::InvalidGeneric)
    end

    it "raises ParseError on bad typedef" do
      expect { described_class.parse("{a:Type}") }.to raise_error(TLParser::ParseError::TypeDef, "{name: a}")
    end

    it "raises ParseError on bad def" do
      expect { described_class.parse("{a:foo}") }.to raise_error(TLParser::ParseError::MissingDef)
    end

    it "successfully parses valid params" do
      expect(described_class.parse("foo:#")).to eq(described_class.new(
        name: "foo",
        type: TLParser::FlagsParam.new
      ))

      expect(described_class.parse("foo:!bar")).to eq(described_class.new(
        name: "foo",
        type: TLParser::NormalParam.new(
          type: TLParser::Type.new(
            namespace: [] of String,
            name: "bar",
            bare: true,
            generic_ref: true,
            generic_arg: nil
          )
        )
      ))

      expect(described_class.parse("foo:bar.1?baz")).to eq(described_class.new(
        name: "foo",
        type: TLParser::NormalParam.new(
          type: TLParser::Type.new(
            namespace: [] of String,
            name: "baz",
            bare: true,
            generic_ref: false,
            generic_arg: nil
          ),
          flag: TLParser::Flag.new(
            name: "bar",
            index: 1
          )
        )
      ))

      expect(described_class.parse("foo:bar<baz>")).to eq(described_class.new(
        name: "foo",
        type: TLParser::NormalParam.new(
          type: TLParser::Type.new(
            namespace: [] of String,
            name: "bar",
            bare: true,
            generic_ref: false,
            generic_arg: TLParser::Type.parse("baz")
          ),
          flag: nil
        )
      ))

      expect(described_class.parse("foo:bar.1?baz<qux>")).to eq(described_class.new(
        name: "foo",
        type: TLParser::NormalParam.new(
          type: TLParser::Type.new(
            namespace: [] of String,
            name: "baz",
            bare: true,
            generic_ref: false,
            generic_arg: TLParser::Type.parse("qux")
          ),
          flag: TLParser::Flag.new(
            name: "bar",
            index: 1
          )
        )
      ))
    end
  end
end
