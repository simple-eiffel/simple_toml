# S03-CONTRACTS: simple_toml

**BACKWASH** | Date: 2026-01-23

## SIMPLE_TOML Contracts

### Parsing Preconditions

```eiffel
parse (a_toml_text: STRING_32): detachable TOML_TABLE
    require
        not_empty: not a_toml_text.is_empty

parse_file (a_file_path: STRING_32): detachable TOML_TABLE
    require
        not_empty: not a_file_path.is_empty
```

### Parsing Postconditions

```eiffel
parse (a_toml_text: STRING_32): detachable TOML_TABLE
    ensure
        errors_cleared_on_success: Result /= Void implies not has_errors
```

### Building Preconditions

```eiffel
to_toml (a_table: TOML_TABLE): STRING_32
    require
        table_not_void: a_table /= Void
    ensure
        result_not_void: Result /= Void

datetime_value (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER): TOML_DATETIME
    require
        valid_date: a_year >= 0 and a_month >= 1 and a_month <= 12 and a_day >= 1 and a_day <= 31
        valid_time: a_hour >= 0 and a_hour <= 23 and a_minute >= 0 and a_minute <= 59 and a_second >= 0 and a_second <= 60
```

### Query Preconditions

```eiffel
value_at (a_table: TOML_TABLE; a_path: STRING_32): detachable TOML_VALUE
    require
        table_not_void: a_table /= Void
        path_not_empty: not a_path.is_empty
```

## Class Invariants

```eiffel
invariant
    last_errors_attached: last_errors /= Void
    has_errors_definition: has_errors = not last_errors.is_empty
    error_count_definition: error_count = last_errors.count
```

## TOML_TABLE Contracts

```eiffel
put (a_value: TOML_VALUE; a_key: STRING_32)
    require
        value_not_void: a_value /= Void
        key_not_void: a_key /= Void
    ensure
        has_key: has (a_key)
        value_stored: item (a_key) = a_value
```
