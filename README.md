<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_toml

**[Documentation](https://simple-eiffel.github.io/simple_toml/)** | **[GitHub](https://github.com/simple-eiffel/simple_toml)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

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
