# S02-CLASS-CATALOG: simple_toml

**BACKWASH** | Date: 2026-01-23

## Facade Class

| Class | Type | Description |
|-------|------|-------------|
| SIMPLE_TOML | Concrete | High-level parsing and building API |

## Value Classes

| Class | Type | Description |
|-------|------|-------------|
| TOML_VALUE | Deferred | Base class for all TOML values |
| TOML_STRING | Concrete | String value (basic or literal) |
| TOML_INTEGER | Concrete | Integer value (dec/hex/oct/bin) |
| TOML_FLOAT | Concrete | Float value (including inf/nan) |
| TOML_BOOLEAN | Concrete | Boolean value (true/false) |
| TOML_DATETIME | Concrete | Datetime value (offset/local/date/time) |
| TOML_ARRAY | Concrete | Array of values |
| TOML_TABLE | Concrete | Key-value table |

## Parser Classes

| Class | Type | Description |
|-------|------|-------------|
| TOML_LEXER | Concrete | Tokenize TOML input |
| TOML_PARSER | Concrete | Build value tree from tokens |
| TOML_TOKEN | Concrete | Token data holder |

## Value Class Features

### TOML_VALUE (common interface)
- is_string, is_integer, is_float, is_boolean, is_datetime, is_array, is_table
- as_string, as_integer, as_float, as_boolean, as_datetime, as_array, as_table
- to_toml: STRING_32 (serialize)

### TOML_TABLE
- item (key): TOML_VALUE
- string_item (key): STRING_32
- integer_item (key): INTEGER_64
- put (value, key)
- put_string, put_integer, put_float, put_boolean (key, value)
- keys: LIST [STRING_32]
- has (key): BOOLEAN
- count: INTEGER

### TOML_ARRAY
- item (index): TOML_VALUE
- extend (value)
- first, last: TOML_VALUE
- count: INTEGER
- is_empty: BOOLEAN
