# 7S-05-SECURITY: simple_toml


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Security Considerations

### Input Validation
- Lexer validates token format
- Parser validates structure
- Errors reported, not crashes

### File Reading
- File paths not validated (caller responsibility)
- UTF-8 assumed, no BOM handling
- Large files loaded fully into memory

### String Handling
- Escape sequences validated
- Invalid escapes reported as errors
- No arbitrary code execution

### Integer Overflow
- INTEGER_64 for integer values
- Hex/octal/binary converted safely

## Risk Assessment

| Risk | Severity | Status |
|------|----------|--------|
| Malformed input crash | Low | Error handling |
| Path traversal | Low | Caller responsibility |
| Large file DoS | Low | Memory-limited |
| Integer overflow | Low | INTEGER_64 range |

## TOML-Specific Security

- TOML is data-only (no code execution)
- No include directives
- No external references
- Simpler than YAML (no billion laughs attack)

## Recommendations

1. Validate file paths before parsing
2. Set reasonable file size limits
3. Handle parse errors gracefully
4. Don't expose raw error messages to users
