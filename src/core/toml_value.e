note
	description: "[
		Base class for all TOML values.
		TOML supports: strings, integers, floats, booleans, datetimes, arrays, and tables.
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=TOML Spec", "protocol=URI", "src=https://toml.io/en/v1.0.0"

class
	TOML_VALUE

feature -- Type checking

	is_string: BOOLEAN
			-- Is this value a string?
		do
			Result := False
		end

	is_integer: BOOLEAN
			-- Is this value an integer?
		do
			Result := False
		end

	is_float: BOOLEAN
			-- Is this value a float?
		do
			Result := False
		end

	is_boolean: BOOLEAN
			-- Is this value a boolean?
		do
			Result := False
		end

	is_datetime: BOOLEAN
			-- Is this value a datetime?
		do
			Result := False
		end

	is_date: BOOLEAN
			-- Is this value a local date?
		do
			Result := False
		end

	is_time: BOOLEAN
			-- Is this value a local time?
		do
			Result := False
		end

	is_array: BOOLEAN
			-- Is this value an array?
		do
			Result := False
		end

	is_table: BOOLEAN
			-- Is this value a table (mapping)?
		do
			Result := False
		end

	is_inline_table: BOOLEAN
			-- Is this value an inline table?
		do
			Result := False
		end

feature -- Conversion

	as_string: STRING_32
			-- Get string value
		require
			is_string: is_string
		do
			create Result.make_empty
		end

	as_integer: INTEGER_64
			-- Get integer value
		require
			is_integer: is_integer
		do
			Result := 0
		end

	as_float: REAL_64
			-- Get float value
		require
			is_float: is_float
		do
			Result := 0.0
		end

	as_boolean: BOOLEAN
			-- Get boolean value
		require
			is_boolean: is_boolean
		do
			Result := False
		end

	as_array: TOML_ARRAY
			-- Get array value
		require
			is_array: is_array
		do
			check wrong_type: False then end
			create Result.make
		end

	as_table: TOML_TABLE
			-- Get table value
		require
			is_table: is_table
		do
			check wrong_type: False then end
			create Result.make
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			create Result.make_empty
		ensure
			result_not_void: Result /= Void
		end

	to_toml_compact: STRING_32
			-- Convert to compact TOML (no extra whitespace)
		do
			Result := to_toml
		ensure
			result_not_void: Result /= Void
		end

end
