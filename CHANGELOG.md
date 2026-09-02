# Changelog

All notable changes to simple_toml.

## 0.1.1 - 2026-09-01

### Fixed

- `load_file` now decodes the file's bytes as UTF-8 (TOML files are UTF-8 by
  specification). Previously each byte was widened to a character, so every
  non-ASCII value — accents, Hebrew, emoji — arrived as mojibake. Found while
  wiring simple_chat's configuration loading. Regression test with é and ש.

## 0.1.0 - 2026-08

Initial release: parser, typed value tree (`TOML_TABLE` and friends),
serialization, error tracking with `last_errors`.
