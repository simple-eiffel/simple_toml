# S06-BOUNDARIES: simple_toml

**BACKWASH** | Date: 2026-01-23

## System Boundaries

### External Dependencies

```
+----------------+     +------------------+     +------------+
| Application    | --> | simple_toml      | --> | TOML Files |
+----------------+     +------------------+     +------------+
                              |
                              v
                       +----------------+
                       | EiffelBase     |
                       +----------------+
```

### Internal Architecture

```
+------------------+
|   SIMPLE_TOML    |  (Facade)
+------------------+
         |
    +----+----+
    |         |
    v         v
+--------+ +--------+
| Parse  | | Build  |
+--------+ +--------+
    |
    v
+------------------+
|   TOML_LEXER     |  (Tokenize)
+------------------+
    |
    v
+------------------+
|   TOML_PARSER    |  (Parse)
+------------------+
    |
    v
+------------------+
|   TOML_VALUE     |  (Value Tree)
|   hierarchy      |
+------------------+
```

### API Boundary

**Public API** (SIMPLE_TOML):
- parse, parse_file
- to_toml, to_file
- new_table, new_array, *_value
- value_at, string_at, integer_at

**Value API** (TOML_VALUE hierarchy):
- is_* type checks
- as_* type conversions
- to_toml serialization

**Internal API**:
- TOML_LEXER tokens
- TOML_PARSER implementation

## Data Type Boundaries

| TOML Type | Eiffel Type | Notes |
|-----------|-------------|-------|
| string | STRING_32 | Unicode |
| integer | INTEGER_64 | 64-bit |
| float | REAL_64 | IEEE 754 |
| boolean | BOOLEAN | |
| datetime | TOML_DATETIME | Components |
| array | TOML_ARRAY | |
| table | TOML_TABLE | |

## Responsibility Boundaries

### simple_toml Responsible For:
- TOML parsing and validation
- Value tree construction
- Serialization to TOML text
- Error reporting

### Application Responsible For:
- File path management
- Error handling decisions
- Value interpretation
- Configuration logic
