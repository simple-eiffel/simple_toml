# Changelog

All notable changes to simple_toml.

## [Unreleased]

### Fixed
- **Non-ASCII text in a basic string was saved corrupted.** The serializer
  escaped every character beyond ASCII as `\u` followed by EIGHT hex digits
  (`NATURAL_32.to_hex_string`), but TOML's `\u` takes exactly four, so a
  reader - this library's own included - took `\u000000E9` as a NUL followed
  by the text "00E9". Characters up to U+FFFF now get `\u` + 4 digits and
  characters beyond get `\U` + 8, which the lexer already read correctly.
  Found from simple_prompter, whose settings lost a script path with an
  e-acute in it. Test: `test_non_ascii_strings_round_trip` (e-acute, en dash,
  emoji).

### Changed
- Class invariants are O(1) again: clauses that built an MML model (`x_model.count = count`) or walked a collection on every feature call were removed. An invariant runs on every call, so those made each call O(n) and any loop over the object O(n^2); simple_json read a 1434-element array in 158 s under DBC before the fix. Model and per-element facts stay in the postconditions of the features that establish them.

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
