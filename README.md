# simple_toml

TOML parser and writer for Eiffel.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Planned** - Backend for simple_codec

## Overview

Parses and writes [TOML](https://toml.io/) format files. Used as the format for UCF (Universe Configuration Files) in simple_lsp.

```eiffel
toml: SIMPLE_TOML
data: TOML_TABLE

create toml
data := toml.parse_file ("config.toml")

name := data.string_item ("name")
```

## Features (Planned)

- Full TOML v1.0.0 spec compliance
- Tables and inline tables
- Arrays and arrays of tables
- All TOML data types (string, integer, float, boolean, datetime)
- Multi-line strings
- Comments preservation (optional)

## License

MIT License
