note
	description: "[
		TOML lexer - tokenizes TOML source text.
		Handles all TOML 1.0 token types including multi-line strings,
		numbers in various bases, and datetime formats.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_LEXER

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

	make (a_source: STRING_32)
			-- Create lexer for source text
		require
			source_not_void: a_source /= Void
		do
			source := a_source
			position := 1
			line := 1
			column := 1
			token_make (Token_eof, "", 1, 1)
		ensure
			source_set: source = a_source
			at_start: position = 1
			line_one: line = 1
			column_one: column = 1
		end

feature -- Access

	source: STRING_32
			-- Source text being lexed

	position: INTEGER
			-- Current position in source (1-based)

	current_token: TOML_TOKEN
			-- Most recently scanned token
		do
			create Result.make (type, value, line, column)
		end

feature -- Status report

	is_at_end: BOOLEAN
			-- Have we reached end of source?
		do
			Result := position > source.count
		end

feature -- Scanning

	next_token: TOML_TOKEN
			-- Scan and return the next token
		local
			l_start_line, l_start_column: INTEGER
		do
			skip_whitespace_and_comments

			l_start_line := line
			l_start_column := column

			if is_at_end then
				create Result.make (Token_eof, "", l_start_line, l_start_column)
			else
				Result := scan_token (l_start_line, l_start_column)
			end

			type := Result.type
			value := Result.value
		end

feature {NONE} -- Implementation

	scan_token (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan a single token
		require
			not_at_end: not is_at_end
		local
			c: CHARACTER_32
		do
			c := current_char

			inspect c
			when '%N', '%R' then
				Result := scan_newline (a_line, a_column)
			when '=' then
				advance
				create Result.make (Token_equals, "=", a_line, a_column)
			when '.' then
				advance
				create Result.make (Token_dot, ".", a_line, a_column)
			when ',' then
				advance
				create Result.make (Token_comma, ",", a_line, a_column)
			when '[' then
				Result := scan_bracket (a_line, a_column)
			when ']' then
				Result := scan_close_bracket (a_line, a_column)
			when '{' then
				advance
				create Result.make (Token_lbrace, "{", a_line, a_column)
			when '}' then
				advance
				create Result.make (Token_rbrace, "}", a_line, a_column)
			when '"' then
				Result := scan_basic_string (a_line, a_column)
			when '%'' then
				Result := scan_literal_string (a_line, a_column)
			when '+', '-' then
				Result := scan_number_or_datetime (a_line, a_column)
			when '0' .. '9' then
				Result := scan_number_or_datetime (a_line, a_column)
			else
				if is_bare_key_char (c) then
					Result := scan_bare_key_or_keyword (a_line, a_column)
				else
					advance
					create Result.make (Token_error, "Unexpected character: " + c.out, a_line, a_column)
				end
			end
		end

	scan_newline (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan newline (handles both LF and CRLF)
		do
			if current_char = '%R' then
				advance
				if not is_at_end and current_char = '%N' then
					advance
				end
			else
				advance
			end
			line := line + 1
			column := 1
			create Result.make (Token_newline, "%N", a_line, a_column)
		end

	scan_bracket (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan [ or [[
		do
			advance
			if not is_at_end and current_char = '[' then
				advance
				create Result.make (Token_double_lbracket, "[[", a_line, a_column)
			else
				create Result.make (Token_lbracket, "[", a_line, a_column)
			end
		end

	scan_close_bracket (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan ] or ]]
		do
			advance
			if not is_at_end and current_char = ']' then
				advance
				create Result.make (Token_double_rbracket, "]]", a_line, a_column)
			else
				create Result.make (Token_rbracket, "]", a_line, a_column)
			end
		end

	scan_basic_string (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan basic string (double-quoted)
		local
			l_value: STRING_32
			l_is_multiline: BOOLEAN
		do
			advance -- skip opening quote

			-- Check for multi-line
			if not is_at_end and current_char = '"' then
				advance
				if not is_at_end and current_char = '"' then
					advance
					l_is_multiline := True
				else
					-- Empty string
					create Result.make (Token_basic_string, "", a_line, a_column)
				end
			end

			if Result = Void then
				l_value := scan_basic_string_content (l_is_multiline)
				if l_is_multiline then
					create Result.make (Token_ml_basic_string, l_value, a_line, a_column)
				else
					create Result.make (Token_basic_string, l_value, a_line, a_column)
				end
			end
		end

	scan_basic_string_content (a_multiline: BOOLEAN): STRING_32
			-- Scan content of basic string
		local
			l_done: BOOLEAN
			c: CHARACTER_32
		do
			create Result.make (50)

			from
				l_done := False
			until
				l_done or is_at_end
			loop
				c := current_char

				if c = '"' then
					if a_multiline then
						-- Check for closing """
						if peek_char (1) = '"' and peek_char (2) = '"' then
							advance
							advance
							advance
							l_done := True
						else
							Result.append_character (c)
							advance
						end
					else
						advance -- skip closing quote
						l_done := True
					end
				elseif c = '\' then
					Result.append_character (scan_escape_sequence (a_multiline))
				elseif c = '%N' or c = '%R' then
					if a_multiline then
						Result.append_character (c)
						if c = '%R' and not is_at_end and peek_char (1) = '%N' then
							advance
							Result.append_character ('%N')
						end
						advance
						line := line + 1
						column := 1
					else
						l_done := True -- Error: newline in single-line string
					end
				else
					Result.append_character (c)
					advance
				end
			end
		end

	scan_escape_sequence (a_multiline: BOOLEAN): CHARACTER_32
			-- Scan escape sequence and return the character
		local
			c: CHARACTER_32
			l_hex: STRING_32
			l_code: INTEGER
		do
			advance -- skip backslash

			if is_at_end then
				Result := '\'
			else
				c := current_char
				advance

				inspect c
				when 'b' then Result := '%B'
				when 't' then Result := '%T'
				when 'n' then Result := '%N'
				when 'f' then Result := '%F'
				when 'r' then Result := '%R'
				when '"' then Result := '"'
				when '\' then Result := '\'
				when 'u' then
					-- Unicode \uXXXX
					l_hex := scan_hex_digits (4)
					l_code := hex_to_integer (l_hex)
					Result := l_code.to_character_32
				when 'U' then
					-- Unicode \UXXXXXXXX
					l_hex := scan_hex_digits (8)
					l_code := hex_to_integer (l_hex)
					Result := l_code.to_character_32
				when '%N', '%R', ' ', '%T' then
					-- Line ending backslash in multi-line string
					if a_multiline then
						skip_to_content
						Result := '%U' -- null, will be filtered
					else
						Result := c
					end
				else
					Result := c
				end
			end
		end

	scan_hex_digits (a_count: INTEGER): STRING_32
			-- Scan exactly count hex digits
		require
			positive_count: a_count > 0
		local
			i: INTEGER
		do
			create Result.make (a_count)
			from
				i := 1
			until
				i > a_count or is_at_end
			loop
				if is_hex_digit (current_char) then
					Result.append_character (current_char)
					advance
				end
				i := i + 1
			end
		end

	scan_literal_string (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan literal string (single-quoted)
		local
			l_value: STRING_32
			l_is_multiline: BOOLEAN
		do
			advance -- skip opening quote

			-- Check for multi-line
			if not is_at_end and current_char = '%'' then
				advance
				if not is_at_end and current_char = '%'' then
					advance
					l_is_multiline := True
				else
					-- Empty string
					create Result.make (Token_literal_string, "", a_line, a_column)
				end
			end

			if Result = Void then
				l_value := scan_literal_string_content (l_is_multiline)
				if l_is_multiline then
					create Result.make (Token_ml_literal_string, l_value, a_line, a_column)
				else
					create Result.make (Token_literal_string, l_value, a_line, a_column)
				end
			end
		end

	scan_literal_string_content (a_multiline: BOOLEAN): STRING_32
			-- Scan content of literal string (no escape processing)
		local
			l_done: BOOLEAN
			c: CHARACTER_32
		do
			create Result.make (50)

			from
				l_done := False
			until
				l_done or is_at_end
			loop
				c := current_char

				if c = '%'' then
					if a_multiline then
						if peek_char (1) = '%'' and peek_char (2) = '%'' then
							advance
							advance
							advance
							l_done := True
						else
							Result.append_character (c)
							advance
						end
					else
						advance
						l_done := True
					end
				elseif c = '%N' or c = '%R' then
					if a_multiline then
						Result.append_character (c)
						if c = '%R' and not is_at_end and peek_char (1) = '%N' then
							advance
							Result.append_character ('%N')
						end
						advance
						line := line + 1
						column := 1
					else
						l_done := True
					end
				else
					Result.append_character (c)
					advance
				end
			end
		end

	scan_bare_key_or_keyword (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan bare key or keyword (true/false/inf/nan)
		local
			l_value: STRING_32
		do
			create l_value.make (20)

			from
			until
				is_at_end or else not is_bare_key_char (current_char)
			loop
				l_value.append_character (current_char)
				advance
			end

			if l_value.same_string ("true") or l_value.same_string ("false") then
				create Result.make (Token_boolean, l_value, a_line, a_column)
			elseif l_value.same_string ("inf") or l_value.same_string ("nan") then
				create Result.make (Token_float, l_value, a_line, a_column)
			else
				create Result.make (Token_bare_key, l_value, a_line, a_column)
			end
		end

	scan_number_or_datetime (a_line, a_column: INTEGER): TOML_TOKEN
			-- Scan number or datetime
		local
			l_value: STRING_32
			l_has_date_sep, l_has_time_sep, l_has_decimal, l_has_exp: BOOLEAN
			l_is_hex, l_is_oct, l_is_bin: BOOLEAN
			l_done: BOOLEAN
			c: CHARACTER_32
		do
			create l_value.make (30)

			-- Handle sign
			if current_char = '+' or current_char = '-' then
				l_value.append_character (current_char)
				advance
			end

			-- Check for hex/octal/binary
			if not is_at_end and current_char = '0' then
				l_value.append_character (current_char)
				advance
				if not is_at_end then
					c := current_char
					if c = 'x' or c = 'X' then
						l_is_hex := True
						l_value.append_character (c)
						advance
					elseif c = 'o' or c = 'O' then
						l_is_oct := True
						l_value.append_character (c)
						advance
					elseif c = 'b' or c = 'B' then
						l_is_bin := True
						l_value.append_character (c)
						advance
					end
				end
			end

			-- Scan remaining digits
			from
				l_done := False
			until
				l_done or is_at_end
			loop
				c := current_char

				if c = '_' then
					-- Skip underscores (visual separators)
					advance
				elseif c = '-' and not l_has_date_sep and l_value.count = 4 then
					-- Date separator (YYYY-MM-DD)
					l_has_date_sep := True
					l_value.append_character (c)
					advance
				elseif c = '-' and l_has_date_sep then
					l_value.append_character (c)
					advance
				elseif c = ':' then
					-- Time separator
					l_has_time_sep := True
					l_value.append_character (c)
					advance
				elseif (c = 'T' or c = 't' or c = ' ') and l_has_date_sep then
					-- Date-time separator
					l_value.append_character (c)
					advance
				elseif c = '.' then
					l_has_decimal := True
					l_value.append_character (c)
					advance
				elseif c = 'e' or c = 'E' then
					l_has_exp := True
					l_value.append_character (c)
					advance
					-- Handle exponent sign
					if not is_at_end and (current_char = '+' or current_char = '-') then
						l_value.append_character (current_char)
						advance
					end
				elseif c = '+' and l_has_time_sep then
					-- Timezone offset
					l_value.append_character (c)
					advance
				elseif c = 'Z' or c = 'z' then
					-- UTC timezone
					l_value.append_character (c)
					advance
				elseif is_digit (c) or (l_is_hex and is_hex_digit (c)) then
					l_value.append_character (c)
					advance
				else
					-- End of number/datetime
					l_done := True
				end
			end

			-- Determine token type
			if l_has_date_sep or l_has_time_sep then
				create Result.make (Token_datetime, l_value, a_line, a_column)
			elseif l_has_decimal or l_has_exp then
				create Result.make (Token_float, l_value, a_line, a_column)
			else
				create Result.make (Token_integer, l_value, a_line, a_column)
			end
		end

feature {NONE} -- Character operations

	current_char: CHARACTER_32
			-- Current character
		require
			not_at_end: not is_at_end
		do
			Result := source [position]
		end

	peek_char (a_offset: INTEGER): CHARACTER_32
			-- Character at offset from current position
		do
			if position + a_offset <= source.count then
				Result := source [position + a_offset]
			else
				Result := '%U' -- null
			end
		end

	advance
			-- Move to next character
		require
			not_at_end: not is_at_end
		do
			position := position + 1
			column := column + 1
		end

	skip_whitespace_and_comments
			-- Skip whitespace (space, tab) and comments
		local
			l_done: BOOLEAN
		do
			from
				l_done := False
			until
				l_done or is_at_end
			loop
				if current_char = ' ' or current_char = '%T' then
					advance
				elseif current_char = '#' then
					-- Skip comment to end of line
					from
					until
						is_at_end or else current_char = '%N' or else current_char = '%R'
					loop
						advance
					end
				else
					l_done := True
				end
			end
		end

	skip_to_content
			-- Skip whitespace and newlines (for multi-line string continuation)
		do
			from
			until
				is_at_end or else not (current_char = ' ' or current_char = '%T' or current_char = '%N' or current_char = '%R')
			loop
				if current_char = '%N' or current_char = '%R' then
					line := line + 1
					column := 1
				end
				advance
			end
		end

	is_bare_key_char (a_c: CHARACTER_32): BOOLEAN
			-- Is c valid in a bare key?
		do
			Result := (a_c >= 'A' and a_c <= 'Z') or
					  (a_c >= 'a' and a_c <= 'z') or
					  (a_c >= '0' and a_c <= '9') or
					  a_c = '_' or a_c = '-'
		end

	is_digit (a_c: CHARACTER_32): BOOLEAN
			-- Is c a decimal digit?
		do
			Result := a_c >= '0' and a_c <= '9'
		end

	is_hex_digit (a_c: CHARACTER_32): BOOLEAN
			-- Is c a hexadecimal digit?
		do
			Result := (a_c >= '0' and a_c <= '9') or
					  (a_c >= 'a' and a_c <= 'f') or
					  (a_c >= 'A' and a_c <= 'F')
		end

	hex_to_integer (a_hex: STRING_32): INTEGER
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

feature -- Output

	debug_output: STRING
			-- String representation for debugging
		do
			Result := "Lexer at " + line.out + ":" + column.out
		end

invariant
	source_not_void: source /= Void
	valid_position: position >= 1
	valid_line: line >= 1
	valid_column: column >= 1

end
