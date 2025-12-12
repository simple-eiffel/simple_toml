note
	description: "[
		Simple, high-level API for working with TOML (Tom's Obvious Minimal Language).
		TOML v1.0.0 compliant parser and writer.

		Usage:
			toml: SIMPLE_TOML
			data: TOML_TABLE

			create toml
			data := toml.parse_file ("config.toml")

			if attached data then
				name := data.string_item ("name")
				version := data.string_item ("version")
			else
				print (toml.errors_as_string)
			end
		]"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=TOML Specification", "protocol=URI", "src=https://toml.io/en/v1.0.0"

class
	SIMPLE_TOML

feature -- Parsing

	parse,
	from_string,
	parse_text (a_toml_text: STRING_32): detachable TOML_TABLE
			-- Parse TOML text and return root table.
			-- On error, returns Void and populates `last_errors' with details.
		require
			not_empty: not a_toml_text.is_empty
		local
			l_lexer: TOML_LEXER
			l_parser: TOML_PARSER
		do
			clear_errors
			last_toml_text := a_toml_text

			create l_lexer.make (a_toml_text)
			create l_parser.make (l_lexer)

			Result := l_parser.parse

			if l_parser.has_errors then
				across l_parser.errors as ic loop
					last_errors.extend (ic)
				end
			end
		ensure
			errors_cleared_on_success: Result /= Void implies not has_errors
		end

	parse_file,
	load,
	load_file (a_file_path: STRING_32): detachable TOML_TABLE
			-- Parse TOML from file and return root table.
			-- On error, returns Void and populates `last_errors' with details.
		require
			not_empty: not a_file_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			clear_errors

			create l_file.make_with_name (a_file_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				l_file.close
				Result := parse (l_content)
			else
				last_errors.extend ("Cannot read file: " + a_file_path)
			end
		end

	is_valid_toml (a_toml_text: STRING_32): BOOLEAN
			-- Check if text is valid TOML without returning the table.
			-- On invalid TOML, populates `last_errors' with details.
		require
			not_empty: not a_toml_text.is_empty
		do
			Result := parse (a_toml_text) /= Void
		ensure
			valid_implies_no_errors: Result implies not has_errors
		end

feature -- Writing

	to_toml,
	to_string,
	serialize (a_table: TOML_TABLE): STRING_32
			-- Convert table to TOML text
		require
			table_not_void: a_table /= Void
		do
			Result := a_table.to_toml_full ("")
		ensure
			result_not_void: Result /= Void
		end

	to_file,
	save,
	save_file (a_table: TOML_TABLE; a_file_path: STRING_32)
			-- Write table to file as TOML
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_file_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING_32
		do
			clear_errors
			l_content := to_toml (a_table)

			create l_file.make_create_read_write (a_file_path)
			l_file.put_string (l_content.to_string_8)
			l_file.close
		end

feature -- Error Tracking

	has_errors: BOOLEAN
			-- Were there errors during the last operation?
		do
			Result := not last_errors.is_empty
		ensure
			definition: Result = not last_errors.is_empty
		end

	last_errors: ARRAYED_LIST [STRING_32]
			-- Errors from the last operation
		attribute
			create Result.make (0)
		end

	error_count: INTEGER
			-- Number of errors from last operation
		do
			Result := last_errors.count
		ensure
			definition: Result = last_errors.count
		end

	first_error: detachable STRING_32
			-- First error from last operation, if any
		do
			if not last_errors.is_empty then
				Result := last_errors.first
			end
		ensure
			has_error_implies_result: has_errors implies Result /= Void
			no_error_implies_void: not has_errors implies Result = Void
		end

	errors_as_string: STRING_32
			-- All errors formatted as a single string
		do
			create Result.make_empty
			across last_errors as ic loop
				if not Result.is_empty then
					Result.append ("%N")
				end
				Result.append (ic)
			end
		end

	clear_errors
			-- Clear all error information
		do
			last_errors.wipe_out
		ensure
			no_errors: not has_errors
			empty_list: last_errors.is_empty
		end

feature -- Building

	new_table,
	create_table,
	table: TOML_TABLE
			-- Create a new empty table
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
			empty: Result.is_empty
		end

	new_inline_table: TOML_TABLE
			-- Create a new empty inline table
		do
			create Result.make_inline
		ensure
			result_not_void: Result /= Void
			empty: Result.is_empty
			is_inline: Result.is_inline_table
		end

	new_array,
	create_array,
	array: TOML_ARRAY
			-- Create a new empty array
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
			empty: Result.is_empty
		end

	string_value (a_string: STRING_32): TOML_STRING
			-- Create a TOML string value
		require
			string_not_void: a_string /= Void
		do
			create Result.make (a_string)
		ensure
			result_not_void: Result /= Void
		end

	literal_string_value (a_string: STRING_32): TOML_STRING
			-- Create a TOML literal string value (no escaping)
		require
			string_not_void: a_string /= Void
		do
			create Result.make_literal (a_string)
		ensure
			result_not_void: Result /= Void
			is_literal: Result.is_literal
		end

	integer_value (a_value: INTEGER_64): TOML_INTEGER
			-- Create a TOML integer value
		do
			create Result.make (a_value)
		ensure
			result_not_void: Result /= Void
		end

	float_value (a_value: REAL_64): TOML_FLOAT
			-- Create a TOML float value
		do
			create Result.make (a_value)
		ensure
			result_not_void: Result /= Void
		end

	boolean_value (a_value: BOOLEAN): TOML_BOOLEAN
			-- Create a TOML boolean value
		do
			create Result.make (a_value)
		ensure
			result_not_void: Result /= Void
		end

	datetime_value (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER): TOML_DATETIME
			-- Create a local datetime value
		require
			valid_date: a_year >= 0 and a_month >= 1 and a_month <= 12 and a_day >= 1 and a_day <= 31
			valid_time: a_hour >= 0 and a_hour <= 23 and a_minute >= 0 and a_minute <= 59 and a_second >= 0 and a_second <= 60
		do
			create Result.make_local_datetime (a_year, a_month, a_day, a_hour, a_minute, a_second)
		ensure
			result_not_void: Result /= Void
		end

	date_value (a_year, a_month, a_day: INTEGER): TOML_DATETIME
			-- Create a local date value
		require
			valid_date: a_year >= 0 and a_month >= 1 and a_month <= 12 and a_day >= 1 and a_day <= 31
		do
			create Result.make_local_date (a_year, a_month, a_day)
		ensure
			result_not_void: Result /= Void
		end

	time_value (a_hour, a_minute, a_second: INTEGER): TOML_DATETIME
			-- Create a local time value
		require
			valid_time: a_hour >= 0 and a_hour <= 23 and a_minute >= 0 and a_minute <= 59 and a_second >= 0 and a_second <= 60
		do
			create Result.make_local_time (a_hour, a_minute, a_second)
		ensure
			result_not_void: Result /= Void
		end

feature -- Querying

	value_at,
	get,
	lookup (a_table: TOML_TABLE; a_path: STRING_32): detachable TOML_VALUE
			-- Get value at dotted path (e.g., "database.server.host")
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		local
			l_keys: LIST [STRING_32]
			l_current: detachable TOML_VALUE
		do
			l_keys := a_path.split ('.')
			l_current := a_table

			across l_keys as ic until l_current = Void loop
				if attached l_current and then l_current.is_table then
					l_current := l_current.as_table.item (ic)
				else
					l_current := Void
				end
			end

			Result := l_current
		end

	string_at,
	get_string (a_table: TOML_TABLE; a_path: STRING_32): detachable STRING_32
			-- Get string value at dotted path
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached value_at (a_table, a_path) as l_val and then l_val.is_string then
				Result := l_val.as_string
			end
		end

	integer_at,
	get_integer (a_table: TOML_TABLE; a_path: STRING_32): INTEGER_64
			-- Get integer value at dotted path (0 if not found)
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached value_at (a_table, a_path) as l_val and then l_val.is_integer then
				Result := l_val.as_integer
			end
		end

	boolean_at,
	get_boolean (a_table: TOML_TABLE; a_path: STRING_32): BOOLEAN
			-- Get boolean value at dotted path (False if not found)
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached value_at (a_table, a_path) as l_val and then l_val.is_boolean then
				Result := l_val.as_boolean
			end
		end

	table_at (a_table: TOML_TABLE; a_path: STRING_32): detachable TOML_TABLE
			-- Get table value at dotted path
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached value_at (a_table, a_path) as l_val and then l_val.is_table then
				Result := l_val.as_table
			end
		end

	array_at (a_table: TOML_TABLE; a_path: STRING_32): detachable TOML_ARRAY
			-- Get array value at dotted path
		require
			table_not_void: a_table /= Void
			path_not_empty: not a_path.is_empty
		do
			if attached value_at (a_table, a_path) as l_val and then l_val.is_array then
				Result := l_val.as_array
			end
		end

feature {NONE} -- Implementation

	last_toml_text: detachable STRING_32
			-- The TOML text from the last parse operation

invariant
	last_errors_attached: last_errors /= Void
	has_errors_definition: has_errors = not last_errors.is_empty
	error_count_definition: error_count = last_errors.count

end
