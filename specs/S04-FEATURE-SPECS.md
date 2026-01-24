# S04-FEATURE-SPECS: simple_toml

**BACKWASH** | Date: 2026-01-23

## SIMPLE_TOML Features

### Parsing

| Feature | Signature | Description |
|---------|-----------|-------------|
| parse / from_string / parse_text | (text: STRING_32): TOML_TABLE | Parse TOML text |
| parse_file / load / load_file | (path: STRING_32): TOML_TABLE | Parse from file |
| is_valid_toml | (text: STRING_32): BOOLEAN | Validate TOML |

### Writing

| Feature | Signature | Description |
|---------|-----------|-------------|
| to_toml / to_string / serialize | (table: TOML_TABLE): STRING_32 | Serialize to TOML |
| to_file / save / save_file | (table, path) | Save to file |

### Building

| Feature | Signature | Description |
|---------|-----------|-------------|
| new_table / create_table / table | : TOML_TABLE | Create empty table |
| new_inline_table | : TOML_TABLE | Create inline table |
| new_array / create_array / array | : TOML_ARRAY | Create empty array |
| string_value | (s: STRING_32): TOML_STRING | Create string |
| literal_string_value | (s: STRING_32): TOML_STRING | Create literal string |
| integer_value | (v: INTEGER_64): TOML_INTEGER | Create integer |
| float_value | (v: REAL_64): TOML_FLOAT | Create float |
| boolean_value | (v: BOOLEAN): TOML_BOOLEAN | Create boolean |
| datetime_value | (y, m, d, h, min, s): TOML_DATETIME | Create datetime |
| date_value | (y, m, d): TOML_DATETIME | Create date |
| time_value | (h, m, s): TOML_DATETIME | Create time |

### Querying

| Feature | Signature | Description |
|---------|-----------|-------------|
| value_at / get / lookup | (table, path): TOML_VALUE | Get by dotted path |
| string_at / get_string | (table, path): STRING_32 | Get string |
| integer_at / get_integer | (table, path): INTEGER_64 | Get integer |
| boolean_at / get_boolean | (table, path): BOOLEAN | Get boolean |
| table_at | (table, path): TOML_TABLE | Get sub-table |
| array_at | (table, path): TOML_ARRAY | Get array |

### Error Handling

| Feature | Signature | Description |
|---------|-----------|-------------|
| has_errors | : BOOLEAN | Has parse errors |
| last_errors | : ARRAYED_LIST [STRING_32] | Error list |
| error_count | : INTEGER | Error count |
| first_error | : detachable STRING_32 | First error |
| errors_as_string | : STRING_32 | All errors |
| clear_errors | | Clear errors |
