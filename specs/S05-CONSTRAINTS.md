# S05-CONSTRAINTS: simple_toml

**BACKWASH** | Date: 2026-01-23

## Technical Constraints

### TOML Spec Constraints
- **TOML Version**: 1.0.0 only
- **Key Names**: Any Unicode, quoted if special chars
- **String Escapes**: Basic strings only
- **Array Homogeneity**: Not enforced (TOML 1.0 relaxed this)

### Type Constraints
- **Integers**: INTEGER_64 range
- **Floats**: REAL_64 range
- **Strings**: STRING_32 (Unicode)
- **Datetimes**: Year, month, day, hour, minute, second components

### Parsing Constraints
- **Full Text**: Entire document in memory
- **No Streaming**: Not a SAX-style parser
- **Error Recovery**: Stop on first serious error

## Design Constraints

### Value Types
- All values inherit TOML_VALUE
- Type checking via is_* queries
- Type conversion via as_* queries
- Invalid conversion returns default/Void

### Table Keys
- Case-sensitive
- Can contain dots (quoted)
- Dotted keys expanded to nested tables

### Array Constraints
- Can contain mixed types
- Arrays of tables have special syntax [[name]]
- Inline arrays on single line

## Parser Constraints

### Lexer
- Recognizes all TOML tokens
- Handles multiline strings
- Reports position on errors

### Parser
- Recursive descent
- Builds complete tree before returning
- Detects duplicate keys
