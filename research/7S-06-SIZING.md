# 7S-06-SIZING: simple_toml


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Codebase Metrics

- **Source Files**: 20+ .e files
- **Core Classes**: ~15 classes
- **LOC Estimate**: ~3,000 lines

## Class Categories

| Category | Count | Classes |
|----------|-------|---------|
| Facade | 1 | SIMPLE_TOML |
| Parser | 3 | TOML_LEXER, TOML_PARSER, TOML_TOKEN |
| Values | 8 | TOML_VALUE, STRING, INTEGER, FLOAT, BOOLEAN, DATETIME, ARRAY, TABLE |

## Value Class Hierarchy

```
TOML_VALUE (deferred)
    |
    +-- TOML_STRING
    +-- TOML_INTEGER
    +-- TOML_FLOAT
    +-- TOML_BOOLEAN
    +-- TOML_DATETIME
    +-- TOML_ARRAY
    +-- TOML_TABLE
```

## Parser Complexity

| Component | Complexity | Notes |
|-----------|------------|-------|
| Lexer | Medium | Token recognition, string escapes |
| Parser | High | Nested tables, arrays of tables |
| Values | Low | Simple data holders |
| Serializer | Medium | TOML output formatting |

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|------------|-------|
| Parse | O(n) | n = input size |
| Serialize | O(n) | n = tree size |
| Lookup | O(k) | k = path depth |
