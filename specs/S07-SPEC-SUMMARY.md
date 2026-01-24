# S07-SPEC-SUMMARY: simple_toml

**BACKWASH** | Date: 2026-01-23

## Executive Summary

**simple_toml** provides TOML 1.0.0 parsing and generation:

1. **Parse**: Text and file input
2. **Build**: Programmatic table construction
3. **Query**: Dotted path value access
4. **Serialize**: Table to TOML text
5. **Types**: Full TOML type support

## Architecture Overview

```
+----------------------------------+
|          SIMPLE_TOML             |
+----------------------------------+
| parse(text) -> TOML_TABLE        |
| to_toml(table) -> STRING         |
| value_at(table, path) -> VALUE   |
| new_table() -> TOML_TABLE        |
| new_array() -> TOML_ARRAY        |
| *_value() -> TOML_*              |
+----------------------------------+
              |
     +--------+--------+
     |                 |
     v                 v
+----------+    +-------------+
|TOML_LEXER|    | TOML_VALUE  |
+----------+    | hierarchy   |
     |          +-------------+
     v
+----------+
|TOML_PARSER|
+----------+
```

## Value Type Hierarchy

```
TOML_VALUE
    |
    +-- TOML_STRING (basic, literal, multiline)
    +-- TOML_INTEGER (dec, hex, oct, bin)
    +-- TOML_FLOAT (normal, inf, nan)
    +-- TOML_BOOLEAN (true, false)
    +-- TOML_DATETIME (offset, local, date, time)
    +-- TOML_ARRAY (mixed types ok)
    +-- TOML_TABLE (regular, inline)
```

## Key Design Decisions

1. **Pure Eiffel**: No external dependencies
2. **Full Spec**: TOML 1.0.0 compliance
3. **Type-Safe**: Typed value classes
4. **Convenient**: Dotted path queries
5. **Contracts**: DBC throughout

## Status

- **Phase**: 5 (Test Coverage)
- **Stability**: High
- **Compliance**: TOML 1.0.0
