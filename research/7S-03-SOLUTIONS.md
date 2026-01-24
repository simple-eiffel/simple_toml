# 7S-03-SOLUTIONS: simple_toml


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Alternative Solutions Considered

### 1. JSON for configuration
- **Pros**: Widely supported, existing simple_json library
- **Cons**: No comments, verbose, not human-friendly
- **Decision**: TOML better for config files

### 2. INI files
- **Pros**: Simple, familiar
- **Cons**: Limited type support, no nested structures, no standard
- **Decision**: TOML is modern INI replacement

### 3. YAML
- **Pros**: Human-readable, widely used
- **Cons**: Complex spec, whitespace-sensitive, security concerns
- **Decision**: TOML simpler and safer

### 4. External TOML library
- **Pros**: Battle-tested
- **Cons**: C/C++ dependency, FFI complexity
- **Decision**: Pure Eiffel implementation preferred

## Chosen Approach

**Pure Eiffel TOML 1.0.0 parser and writer**

- TOML_LEXER: Tokenize TOML text
- TOML_PARSER: Build value tree from tokens
- TOML_VALUE hierarchy: Type-safe value classes
- SIMPLE_TOML: High-level facade

## Trade-offs Accepted

- Full implementation requires significant code
- Datetime handling without DATE_TIME library dependency
- No streaming parser (full text in memory)
