require "../spec_helper"

Spectator.describe TLParser::Definition do
  describe "#parse" do
    it "raises ParseError on empty def" do
      expect { described_class.parse("") }.to raise_error(TLParser::ParseError::Empty)
    end

    it "raises ParseError on bad id" do
      expect { described_class.parse("foo#bar = baz") }.to raise_error(TLParser::ParseError::InvalidID, "{id: bar}")
      expect { described_class.parse("foo#? = baz") }.to raise_error(TLParser::ParseError::InvalidID, "{id: ?}")
      expect { described_class.parse("foo# = baz") }.to raise_error(TLParser::ParseError::InvalidID, "{id: }")
    end

    it "raises ParseError on missing name" do
      expect { described_class.parse(" = foo") }.to raise_error(TLParser::ParseError::MissingName)
    end

    it "raises ParseError on missing type" do
      expect { described_class.parse("foo") }.to raise_error(TLParser::ParseError::MissingType)
      expect { described_class.parse("foo = ") }.to raise_error(TLParser::ParseError::MissingType)
    end

    it "raises ParseError on unimplemented feature" do
      expect { described_class.parse("int ? = Int") }.to raise_error(TLParser::ParseError::NotImplemented)
    end

    it "allows the id to be overridden" do
      line = "rpc_answer_dropped msg_id:long seq_no:int bytes:int = RpcDropAnswer"
      expect(described_class.parse(line).id).to eq(0xa43ad8b7)

      line = "rpc_answer_dropped#123456 msg_id:long seq_no:int bytes:int = RpcDropAnswer"
      expect(described_class.parse(line).id).to eq(0x123456)
    end

    it "parses valid definitions" do
      defn = described_class.parse("a#1=d")
      expect(defn.name).to eq("a")
      expect(defn.id).to eq(1)
      expect(defn.params.size).to eq(0)
      expect(defn.type).to eq(TLParser::Type.new(
        namespace: [] of String,
        name: "d",
        bare: true,
        generic_ref: false,
        generic_arg: nil
      ))

      defn = described_class.parse("a=d<e>")
      expect(defn.name).to eq("a")
      expect(defn.id).not_to eq(0)
      expect(defn.params.size).to eq(0)
      expect(defn.type).to eq(TLParser::Type.new(
        namespace: [] of String,
        name: "d",
        bare: true,
        generic_ref: false,
        generic_arg: TLParser::Type.parse("e")
      ))

      defn = described_class.parse("a b:c = d")
      expect(defn.name).to eq("a")
      expect(defn.id).not_to eq(0)
      expect(defn.params.size).to eq(1)
      expect(defn.type).to eq(TLParser::Type.new(
        namespace: [] of String,
        name: "d",
        bare: true,
        generic_ref: false,
        generic_arg: nil
      ))

      defn = described_class.parse("a#1 {b:Type} c:!b = d")
      expect(defn.name).to eq("a")
      expect(defn.id).to eq(1)
      expect(defn.params.size).to eq(1)
      expect(defn.type).to eq(TLParser::Type.new(
        namespace: [] of String,
        name: "d",
        bare: true,
        generic_ref: false,
        generic_arg: nil
      ))
    end

    it "parses a multiline definition" do
      defn = "
        first#1 = lol:param
          = t;"

      expect(described_class.parse(defn).id).to eq(1)

      defn = "
        second#2
          lol:String
          = t;
      "

      expect(described_class.parse(defn).id).to eq(2)

      defn = "
      third#3

          lol:String

        =
             t;
      "

      expect(described_class.parse(defn).id).to eq(3)
    end

    it "parses complete definitions" do
      defn = "ns1.name#123 {X:Type} flags:# pname:flags.10?ns2.Vector<!X> = ns3.Type"
      expect(described_class.parse(defn)).to eq(described_class.new(
        namespace: ["ns1"],
        name: "name",
        id: 0x123u32,
        params: [
          TLParser::Parameter.new(
            name: "flags",
            type: TLParser::FlagsParam.new
          ),
          TLParser::Parameter.new(
            name: "pname",
            type: TLParser::NormalParam.new(
              type: TLParser::Type.new(
                namespace: ["ns2"],
                name: "Vector",
                bare: false,
                generic_ref: false,
                generic_arg: TLParser::Type.new(
                  namespace: [] of String,
                  name: "X",
                  bare: false,
                  generic_ref: true,
                  generic_arg: nil
                )
              ),
              flag: TLParser::Flag.new(
                name: "flags",
                index: 10
              )
            )
          )
        ],
        type: TLParser::Type.new(
          namespace: ["ns3"],
          name: "Type",
          bare: false,
          generic_ref: false,
          generic_arg: nil
        ),
        category: TLParser::Category::Types
      ))
    end

    it "raises ParseError on missing generic" do
      defn = "name param:!X = Type"
      expect { described_class.parse(defn) }.to raise_error(TLParser::ParseError::MissingDef)

      defn = "name {X:Type} param:!Y = Type"
      expect { described_class.parse(defn) }.to raise_error(TLParser::ParseError::MissingDef)
    end

    it "raises ParseError on unknown flags" do
      defn = "name param:flags.0?true = Type"
      expect { described_class.parse(defn) }.to raise_error(TLParser::ParseError::MissingDef)

      defn = "name foo:# param:flags.0?true = Type"
      expect { described_class.parse(defn) }.to raise_error(TLParser::ParseError::MissingDef)
    end
  end

  describe "#to_s" do
    it "converts the definition back into a string" do
      defn = "ns1.name#123 {X:Type} flags:# pname:flags.10?ns2.Vector<!X> = ns3.Type"
      expect(described_class.parse(defn).to_s).to eq(defn)
    end
  end
end
