# 7S-02-STANDARDS: simple_toml


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Language Standards

- **Eiffel**: ECMA-367 compliant
- **TOML**: v1.0.0 specification (https://toml.io/en/v1.0.0)

## TOML 1.0.0 Compliance

### Supported Types
| Type | TOML Syntax | Eiffel Class |
|------|-------------|--------------|
| String | "basic" or 'literal' | TOML_STRING |
| Integer | 42, 0xFF, 0o755, 0b1010 | TOML_INTEGER |
| Float | 3.14, inf, nan | TOML_FLOAT |
| Boolean | true, false | TOML_BOOLEAN |
| Datetime | 2024-01-15T10:30:00Z | TOML_DATETIME |
| Array | [1, 2, 3] | TOML_ARRAY |
| Table | [section] | TOML_TABLE |
| Inline Table | {key = "value"} | TOML_TABLE |
| Array of Tables | [[products]] | TOML_ARRAY |

### Supported Features
- Dotted keys: `a.b.c = "value"`
- Multiline strings: `"""..."""` and `'''...'''`
- Escaped characters in basic strings
- Literal strings (no escaping)
- Comments: `# comment`
- Timezone offsets in datetimes

## Simple Eiffel Ecosystem Standards

- Design by Contract (DBC) throughout
- Void safety enabled
- Postconditions on all public features
- ECF-based project configuration
