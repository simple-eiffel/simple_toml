# 7S-01-SCOPE: simple_toml

**BACKWASH** | Date: 2026-01-23

## Problem Domain

Simple_toml provides TOML (Tom's Obvious Minimal Language) v1.0.0 parsing and generation for Eiffel applications.

Key capabilities:
- Parse TOML text and files
- Build TOML documents programmatically
- Query values by dotted paths (e.g., "database.server.host")
- Serialize tables back to TOML format
- Support all TOML 1.0.0 types (string, integer, float, boolean, datetime, array, table)
- Handle special values (infinity, NaN, hex/octal/binary integers)
- Inline tables and arrays of tables

## Target Users

- Eiffel applications using TOML configuration files
- Tools generating TOML output
- Developers needing human-readable config format

## Business Value

- TOML is simpler than JSON for humans
- Widely adopted for config files (Rust Cargo, Python pyproject.toml)
- Full TOML 1.0.0 compliance
- Type-safe value access

## Out of Scope

- TOML schema validation
- Config file watching/reloading
- Encryption of config values
- TOML to JSON/YAML conversion
