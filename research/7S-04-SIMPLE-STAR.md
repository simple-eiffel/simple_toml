# 7S-04-SIMPLE-STAR: simple_toml


**Date**: 2026-01-23

**BACKWASH** | Date: 2026-01-23

## Ecosystem Integration

### Dependencies (Incoming)
- **EiffelBase**: Core data structures

### Dependents (Outgoing)
- **simple_config**: Configuration management (potential)
- Applications using TOML config files

## Integration Patterns

### Parsing TOML
```eiffel
toml: SIMPLE_TOML
data: TOML_TABLE

create toml
data := toml.parse_file ("config.toml")

if data /= Void then
    name := data.string_item ("name")
    version := data.string_item ("version")
else
    print (toml.errors_as_string)
end
```

### Building TOML
```eiffel
table := toml.new_table
table.put_string ("name", "my-app")
table.put_integer ("version", 1)

server := toml.new_table
server.put_string ("host", "localhost")
server.put_integer ("port", 8080)
table.put (server, "server")

print (toml.to_toml (table))
```

### Dotted Path Queries
```eiffel
host := toml.string_at (data, "database.server.host")
port := toml.integer_at (data, "database.server.port")
```

## Ecosystem Fit

- Configuration file handling
- Complements simple_json for different use cases
- Pure Eiffel, no external dependencies
