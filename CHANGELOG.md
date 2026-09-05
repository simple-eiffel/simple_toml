# Changelog

All notable changes to simple_toml.

## 0.1.2 - 2026-09-04

### Fixed

- `TOML_STRING.to_toml` no longer drops non-ASCII characters from a literal
  string. Its quote marks were STRING_8 manifests, so the compiler sent the
  STRING_32 value through the obsolete `as_string_8`, which replaces every code
  point above 255 with a null character: a literal string holding ‎ש‎ or λ was
  written back out with nulls where those letters had been. The quote marks in
  `TOML_STRING.to_toml` and the `0o` / `0b` prefixes in `TOML_INTEGER.to_toml`
  are now `{STRING_32}` manifests, so the whole expression stays 32-bit, which
  is what `to_toml` returns anyway. ASCII output is unchanged character for
  character. Two regression tests: one on a literal string of é, ‎ש‎ and λ, one
  pinning the ASCII forms of all four call sites.

### Changed

- The library target's ECF options now carry
  `<warning name="obsolete_feature" value="all"/>`. Without it the compiler
  only reports that obsolete calls exist "but not reported due to project
  configuration settings", which is how these four sat unseen. The library
  builds at zero warnings.

## 0.1.1 - 2026-09-01

### Fixed

- `load_file` now decodes the file's bytes as UTF-8 (TOML files are UTF-8 by
  specification). Previously each byte was widened to a character, so every
  non-ASCII value — accents, Hebrew, emoji — arrived as mojibake. Found while
  wiring simple_chat's configuration loading. Regression test with é and ש.

## 0.1.0 - 2026-08

Initial release: parser, typed value tree (`TOML_TABLE` and friends),
serialization, error tracking with `last_errors`.
