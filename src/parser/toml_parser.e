note
	description: "[
		TOML parser - builds TOML value tree from tokens.
		Handles all TOML 1.0 features including nested tables,
		arrays of tables, and dotted keys.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_PARSER

inherit
	TOML_TOKEN
		rename
			make as token_make,
			debug_output as token_debug_output
		export
			{NONE} token_make
		end

create
	make

feature {NONE} -- Initialization

	make (a_lexer: TOML_LEXER)
			-- Create parser for lexer
		require
			lexer_not_void: a_lexer /= Void
		do
			lexer := a_lexer
			create errors.make (5)
			current_token := lexer.next_token
			token_make (Token_eof, "", 1, 1)
		ensure
			lexer_set: lexer = a_lexer
			no_errors: not has_errors
		end

feature -- Access

	lexer: TOML_LEXER
			-- Lexer providing tokens

	errors: ARRAYED_LIST [STRING_32]
			-- Parse errors

	current_token: TOML_TOKEN
			-- Current token

feature -- Status report

	has_errors: BOOLEAN
			-- Were there parse errors?
		do
			Result := not errors.is_empty
		end

feature -- Model Queries

	errors_model: MML_SEQUENCE [STRING_32]
			-- Mathematical model of parse errors in order.
		do
			create Result
			across errors as ic loop
				Result := Result & ic
			end
		ensure
			count_matches: Result.count = errors.count
		end

feature -- Parsing

	parse: detachable TOML_TABLE
			-- Parse and return root table
		do
			create Result.make
			parse_document (Result)
			if has_errors then
				Result := Void
			end
		end

feature {NONE} -- Implementation

	parse_document (a_root: TOML_TABLE)
			-- Parse entire TOML document into root table
		require
			root_not_void: a_root /= Void
		local
			l_current_table: TOML_TABLE
			l_done: BOOLEAN
		do
			l_current_table := a_root

			from
				l_done := False
			until
				l_done or current_token.is_eof or has_errors
			loop
				skip_newlines

				if current_token.is_eof then
					l_done := True
				elseif current_token.type = Token_lbracket then
					l_current_table := parse_table_header (a_root)
				elseif current_token.type = Token_double_lbracket then
					l_current_table := parse_array_of_tables_header (a_root)
				elseif is_key_token (current_token) then
					parse_key_value (l_current_table)
				else
					add_error ("Unexpected token: " + current_token.debug_output)
					advance_token
				end
			end
		end

	parse_table_header (a_root: TOML_TABLE): TOML_TABLE
			-- Parse [table.name] header and return target table
		require
			is_bracket: current_token.type = Token_lbracket
		local
			l_keys: ARRAYED_LIST [STRING_32]
		do
			advance_token -- skip [

			l_keys := parse_key_path
			Result := ensure_table_path (a_root, l_keys, False)

			if current_token.type = Token_rbracket then
				advance_token
			else
				add_error ("Expected ']' after table name")
			end

			skip_newlines
		end

	parse_array_of_tables_header (a_root: TOML_TABLE): TOML_TABLE
			-- Parse [[array.of.tables]] header and return target table
		require
			is_double_bracket: current_token.type = Token_double_lbracket
		local
			l_keys: ARRAYED_LIST [STRING_32]
			l_parent: TOML_TABLE
			l_last_key: STRING_32
			l_array: TOML_ARRAY
			l_new_table: TOML_TABLE
		do
			advance_token -- skip [[

			l_keys := parse_key_path

			-- Navigate to parent, get/create array
			if l_keys.count > 1 then
				l_parent := ensure_table_path (a_root, sublist (l_keys, 1, l_keys.count - 1), False)
			else
				l_parent := a_root
			end

			l_last_key := l_keys.last

			-- Get or create array
			if attached l_parent.item (l_last_key) as al_l_existing then
				if al_l_existing.is_array then
					l_array := al_l_existing.as_array
				else
					add_error ({STRING_32} "Key '" + l_last_key + {STRING_32} "' is not an array of tables")
					l_array := Void
				end
			else
				create l_array.make
				l_parent.put (l_array, l_last_key)
			end

			-- Create new table and add to array
			create l_new_table.make
			if l_array /= Void then
				l_array.extend (l_new_table)
			end
			Result := l_new_table

			if current_token.type = Token_double_rbracket then
				advance_token
			else
				add_error ("Expected ']]' after array of tables name")
			end

			skip_newlines
		end

	parse_key_path: ARRAYED_LIST [STRING_32]
			-- Parse dotted key path (a.b.c)
		local
			l_key: STRING_32
		do
			create Result.make (3)

			l_key := parse_key
			if l_key /= Void then
				Result.extend (l_key)
			end

			from
			until
				current_token.type /= Token_dot
			loop
				advance_token -- skip dot
				l_key := parse_key
				if l_key /= Void then
					Result.extend (l_key)
				end
			end
		ensure
			result_not_void: Result /= Void
		end

	parse_key: detachable STRING_32
			-- Parse a single key
		do
			if current_token.type = Token_bare_key then
				Result := current_token.value
				advance_token
			elseif current_token.type = Token_basic_string then
				Result := current_token.value
				advance_token
			elseif current_token.type = Token_literal_string then
				Result := current_token.value
				advance_token
			else
				add_error ("Expected key, got: " + current_token.debug_output)
			end
		end

	parse_key_value (a_table: TOML_TABLE)
			-- Parse key = value pair
		require
			table_not_void: a_table /= Void
		local
			l_keys: ARRAYED_LIST [STRING_32]
			l_target: TOML_TABLE
			l_last_key: STRING_32
			l_value: detachable TOML_VALUE
		do
			l_keys := parse_key_path

			-- Handle dotted keys by navigating/creating intermediate tables
			if l_keys.count > 1 then
				l_target := ensure_table_path (a_table, sublist (l_keys, 1, l_keys.count - 1), True)
			else
				l_target := a_table
			end

			l_last_key := l_keys.last

			if current_token.type = Token_equals then
				advance_token
			else
				add_error ("Expected '=' after key")
			end

			l_value := parse_value

			if l_value /= Void then
				if l_target.has (l_last_key) then
					add_error ({STRING_32} "Duplicate key: " + l_last_key)
				else
					l_target.put (l_value, l_last_key)
				end
			end

			skip_newlines
		end

	parse_value: detachable TOML_VALUE
			-- Parse a value
		do
			inspect current_token.type
			when Token_basic_string, Token_ml_basic_string then
				create {TOML_STRING} Result.make (current_token.value)
				advance_token
			when Token_literal_string, Token_ml_literal_string then
				create {TOML_STRING} Result.make_literal (current_token.value)
				advance_token
			when Token_integer then
				Result := parse_integer
			when Token_float then
				Result := parse_float
			when Token_boolean then
				create {TOML_BOOLEAN} Result.make (current_token.value.same_string ("true"))
				advance_token
			when Token_datetime then
				Result := parse_datetime
			when Token_lbracket then
				Result := parse_array
			when Token_lbrace then
				Result := parse_inline_table
			else
				add_error ("Expected value, got: " + current_token.debug_output)
			end
		end

	parse_integer: TOML_INTEGER
			-- Parse integer value
		local
			l_str: STRING_32
			l_val: INTEGER_64
		do
			l_str := current_token.value.twin
			l_str.prune_all ('_') -- Remove visual separators

			if l_str.starts_with ("0x") or l_str.starts_with ("0X") then
				l_val := hex_string_to_integer (l_str.substring (3, l_str.count))
				create Result.make_hex (l_val)
			elseif l_str.starts_with ("0o") or l_str.starts_with ("0O") then
				l_val := octal_string_to_integer (l_str.substring (3, l_str.count))
				create Result.make_octal (l_val)
			elseif l_str.starts_with ("0b") or l_str.starts_with ("0B") then
				l_val := binary_string_to_integer (l_str.substring (3, l_str.count))
				create Result.make_binary (l_val)
			else
				if l_str.is_integer_64 then
					l_val := l_str.to_integer_64
				end
				create Result.make (l_val)
			end

			advance_token
		end

	parse_float: TOML_FLOAT
			-- Parse float value
		local
			l_str: STRING_32
			l_val: REAL_64
		do
			l_str := current_token.value.twin
			l_str.prune_all ('_')

			if l_str.same_string ("inf") or l_str.same_string ("+inf") then
				create Result.make_infinity (False)
			elseif l_str.same_string ("-inf") then
				create Result.make_infinity (True)
			elseif l_str.same_string ("nan") or l_str.same_string ("+nan") or l_str.same_string ("-nan") then
				create Result.make_nan
			else
				if l_str.is_double then
					l_val := l_str.to_double
				end
				create Result.make (l_val)
			end

			advance_token
		end

	parse_datetime: TOML_DATETIME
			-- Parse datetime value
		local
			l_str: STRING_32
			l_year, l_month, l_day: INTEGER
			l_hour, l_minute, l_second: INTEGER
			l_offset_hours, l_offset_minutes: INTEGER
			l_has_date, l_has_time, l_has_offset: BOOLEAN
			l_pos: INTEGER
		do
			l_str := current_token.value

			-- Try to parse date part (YYYY-MM-DD)
			if l_str.count >= 10 and l_str [5] = '-' and l_str [8] = '-' then
				l_year := l_str.substring (1, 4).to_integer
				l_month := l_str.substring (6, 7).to_integer
				l_day := l_str.substring (9, 10).to_integer
				l_has_date := True
				l_pos := 11
			else
				l_pos := 1
			end

			-- Check for time separator
			if l_pos <= l_str.count and (l_str [l_pos] = 'T' or l_str [l_pos] = 't' or l_str [l_pos] = ' ') then
				l_pos := l_pos + 1
			end

			-- Try to parse time part (HH:MM:SS)
			if l_pos + 7 <= l_str.count and l_str [l_pos + 2] = ':' then
				l_hour := l_str.substring (l_pos, l_pos + 1).to_integer
				l_minute := l_str.substring (l_pos + 3, l_pos + 4).to_integer
				l_second := l_str.substring (l_pos + 6, l_pos + 7).to_integer
				l_has_time := True
				l_pos := l_pos + 8

				-- Skip fractional seconds
				if l_pos <= l_str.count and l_str [l_pos] = '.' then
					from
						l_pos := l_pos + 1
					until
						l_pos > l_str.count or else not l_str [l_pos].is_digit
					loop
						l_pos := l_pos + 1
					end
				end
			elseif not l_has_date and l_str.count >= 8 and l_str [3] = ':' then
				-- Time only (HH:MM:SS)
				l_hour := l_str.substring (1, 2).to_integer
				l_minute := l_str.substring (4, 5).to_integer
				l_second := l_str.substring (7, 8).to_integer
				l_has_time := True
				l_pos := 9
			end

			-- Try to parse timezone offset
			if l_pos <= l_str.count then
				if l_str [l_pos] = 'Z' or l_str [l_pos] = 'z' then
					l_has_offset := True
					l_offset_hours := 0
					l_offset_minutes := 0
				elseif l_str [l_pos] = '+' or l_str [l_pos] = '-' then
					l_has_offset := True
					if l_pos + 5 <= l_str.count then
						l_offset_hours := l_str.substring (l_pos + 1, l_pos + 2).to_integer
						l_offset_minutes := l_str.substring (l_pos + 4, l_pos + 5).to_integer
						if l_str [l_pos] = '-' then
							l_offset_hours := -l_offset_hours
						end
					end
				end
			end

			-- Create appropriate datetime type
			if l_has_date and l_has_time and l_has_offset then
				create Result.make_offset_datetime (l_year, l_month, l_day, l_hour, l_minute, l_second, l_offset_hours, l_offset_minutes)
			elseif l_has_date and l_has_time then
				create Result.make_local_datetime (l_year, l_month, l_day, l_hour, l_minute, l_second)
			elseif l_has_date then
				create Result.make_local_date (l_year, l_month, l_day)
			else
				create Result.make_local_time (l_hour, l_minute, l_second)
			end

			advance_token
		end

	parse_array: TOML_ARRAY
			-- Parse array value
		local
			l_done: BOOLEAN
			l_value: detachable TOML_VALUE
		do
			create Result.make
			advance_token -- skip [

			skip_newlines

			from
				l_done := current_token.type = Token_rbracket
			until
				l_done or current_token.is_eof or has_errors
			loop
				l_value := parse_value
				if l_value /= Void then
					Result.extend (l_value)
				end

				skip_newlines

				if current_token.type = Token_comma then
					advance_token
					skip_newlines
				elseif current_token.type = Token_rbracket then
					l_done := True
				else
					add_error ("Expected ',' or ']' in array")
					l_done := True
				end
			end

			if current_token.type = Token_rbracket then
				advance_token
			else
				add_error ("Expected ']' at end of array")
			end
		end

	parse_inline_table: TOML_TABLE
			-- Parse inline table { key = value, ... }
		local
			l_done: BOOLEAN
		do
			create Result.make_inline
			advance_token -- skip {

			from
				l_done := current_token.type = Token_rbrace
			until
				l_done or current_token.is_eof or has_errors
			loop
				if is_key_token (current_token) then
					parse_inline_key_value (Result)
				else
					add_error ("Expected key in inline table")
					l_done := True
				end

				if current_token.type = Token_comma then
					advance_token
				elseif current_token.type = Token_rbrace then
					l_done := True
				else
					add_error ("Expected ',' or '}' in inline table")
					l_done := True
				end
			end

			if current_token.type = Token_rbrace then
				advance_token
			else
				add_error ("Expected '}' at end of inline table")
			end
		end

	parse_inline_key_value (a_table: TOML_TABLE)
			-- Parse key = value in inline table
		local
			l_key: STRING_32
			l_value: detachable TOML_VALUE
		do
			l_key := parse_key

			if current_token.type = Token_equals then
				advance_token
			else
				add_error ("Expected '=' after key in inline table")
			end

			l_value := parse_value

			if l_key /= Void and l_value /= Void then
				a_table.put (l_value, l_key)
			end
		end

	ensure_table_path (a_root: TOML_TABLE; a_keys: LIST [STRING_32]; a_implicit: BOOLEAN): TOML_TABLE
			-- Navigate key path, creating intermediate tables as needed
		require
			root_not_void: a_root /= Void
			keys_not_void: a_keys /= Void
		local
			l_key: STRING_32
			l_table: TOML_TABLE
			l_new_table: TOML_TABLE
		do
			Result := a_root

			across a_keys as ic loop
				l_key := ic

				if attached Result.item (l_key) as al_l_existing then
					if al_l_existing.is_table then
						Result := al_l_existing.as_table
					elseif al_l_existing.is_array and then not al_l_existing.as_array.is_empty then
						-- For array of tables, use last element
						l_table := al_l_existing.as_array.last.as_table
						Result := l_table
					else
						add_error ({STRING_32} "Key '" + l_key + {STRING_32} "' is not a table")
					end
				else
					create l_new_table.make
					Result.put (l_new_table, l_key)
					Result := l_new_table
				end
			end
		end

feature {NONE} -- Token operations

	advance_token
			-- Move to next token
		do
			current_token := lexer.next_token
		end

	skip_newlines
			-- Skip newline tokens
		do
			from
			until
				current_token.type /= Token_newline
			loop
				advance_token
			end
		end

	is_key_token (a_token: TOML_TOKEN): BOOLEAN
			-- Can this token start a key?
		do
			Result := a_token.type = Token_bare_key or
					  a_token.type = Token_basic_string or
					  a_token.type = Token_literal_string
		end

	add_error (a_message: STRING_32)
			-- Add parse error
		require
			message_not_void: a_message /= Void
		do
			errors.extend (a_message + {STRING_32} " at " + current_token.line.out + {STRING_32} ":" + current_token.column.out)
		ensure
			has_errors: has_errors
		end

feature {NONE} -- List operations

	sublist (a_list: ARRAYED_LIST [STRING_32]; a_start, a_end: INTEGER): ARRAYED_LIST [STRING_32]
			-- Create a sublist from a_start to a_end (inclusive)
		require
			list_not_void: a_list /= Void
			valid_start: a_start >= 1
			valid_end: a_end <= a_list.count
			valid_range: a_start <= a_end
		local
			i: INTEGER
		do
			create Result.make (a_end - a_start + 1)
			from
				i := a_start
			until
				i > a_end
			loop
				Result.extend (a_list [i])
				i := i + 1
			end
		ensure
			result_not_void: Result /= Void
			correct_count: Result.count = a_end - a_start + 1
		end

feature {NONE} -- Number conversion

	hex_string_to_integer (a_hex: STRING_32): INTEGER_64
			-- Convert hex string to integer
		local
			i: INTEGER
			c: CHARACTER_32
			l_digit: INTEGER
		do
			from
				i := 1
			until
				i > a_hex.count
			loop
				c := a_hex [i]
				if c >= '0' and c <= '9' then
					l_digit := c.code - ('0').code
				elseif c >= 'a' and c <= 'f' then
					l_digit := c.code - ('a').code + 10
				elseif c >= 'A' and c <= 'F' then
					l_digit := c.code - ('A').code + 10
				else
					l_digit := 0
				end
				Result := Result * 16 + l_digit
				i := i + 1
			end
		end

	octal_string_to_integer (a_oct: STRING_32): INTEGER_64
			-- Convert octal string to integer
		local
			i: INTEGER
			c: CHARACTER_32
		do
			from
				i := 1
			until
				i > a_oct.count
			loop
				c := a_oct [i]
				if c >= '0' and c <= '7' then
					Result := Result * 8 + (c.code - ('0').code)
				end
				i := i + 1
			end
		end

	binary_string_to_integer (a_bin: STRING_32): INTEGER_64
			-- Convert binary string to integer
		local
			i: INTEGER
			c: CHARACTER_32
		do
			from
				i := 1
			until
				i > a_bin.count
			loop
				c := a_bin [i]
				if c = '0' then
					Result := Result * 2
				elseif c = '1' then
					Result := Result * 2 + 1
				end
				i := i + 1
			end
		end

feature -- Output

	debug_output: STRING
			-- String representation for debugging
		do
			Result := "Parser at token: " + current_token.debug_output
		end

invariant
	lexer_not_void: lexer /= Void
	errors_not_void: errors /= Void

	-- Model consistency
	model_count: errors_model.count = errors.count

end
