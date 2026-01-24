# S01-PROJECT-INVENTORY: simple_toml

**BACKWASH** | Date: 2026-01-23

## Project Structure

```
simple_toml/
├── src/
│   ├── core/
│   │   ├── simple_toml.e           # Main facade
│   │   ├── toml_value.e            # Base value class
│   │   ├── toml_string.e           # String value
│   │   ├── toml_integer.e          # Integer value
│   │   ├── toml_float.e            # Float value
│   │   ├── toml_boolean.e          # Boolean value
│   │   ├── toml_datetime.e         # Datetime value
│   │   ├── toml_array.e            # Array value
│   │   └── toml_table.e            # Table value
│   └── parser/
│       ├── toml_lexer.e            # Tokenizer
│       ├── toml_parser.e           # Parser
│       └── toml_token.e            # Token definition
├── testing/
│   ├── test_app.e                  # Test application
│   └── lib_tests.e                 # Test suite
├── simple_toml.ecf                 # Library ECF
├── research/                       # Research documents
└── specs/                          # Specification documents
```

## Key Files

| File | Purpose |
|------|---------|
| simple_toml.e | High-level facade for parsing and building |
| toml_parser.e | TOML 1.0.0 parser |
| toml_lexer.e | Token generation |
| toml_table.e | Table/object representation |
| toml_value.e | Base class for all values |

## Configuration

- **ECF**: simple_toml.ecf
- **Void Safety**: Complete
- **External Dependencies**: None (pure Eiffel)
