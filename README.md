# TLParser

This library makes parsing `.tl` files with Crystal simple. It's about 95% complete, and will allow the parsing of most [Type Language](https://core.telegram.org/mtproto/TL) grammars.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tl_parser:
       github: protoncr/tl_parser
   ```

2. Run `shards install`

## Usage

```crystal
require "tl_parser"

data = File.read("api.tl")
defs = TLParser.parse(data)

pp defs
```

## Contributing

1. Fork it (<https://github.com/watzon/tl_parser/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Watzon](https://github.com/watzon) - creator and maintainer
