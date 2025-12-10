note
	description: "[
		TOML string value.
		Supports basic strings (double-quoted) and literal strings (single-quoted).
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_STRING

inherit
	TOML_VALUE
		redefine
			is_string,
			as_string,
			to_toml
		end

create
	make,
	make_literal

feature {NONE} -- Initialization

	make (a_value: STRING_32)
			-- Create a basic string value
		require
			value_not_void: a_value /= Void
		do
			value := a_value
			is_literal := False
		ensure
			value_set: value.same_string (a_value)
			not_literal: not is_literal
		end

	make_literal (a_value: STRING_32)
			-- Create a literal string value (no escape processing)
		require
			value_not_void: a_value /= Void
		do
			value := a_value
			is_literal := True
		ensure
			value_set: value.same_string (a_value)
			is_literal_set: is_literal
		end

feature -- Access

	value: STRING_32
			-- The string value

	is_literal: BOOLEAN
			-- Is this a literal string (single quotes, no escaping)?

feature -- Type checking

	is_string: BOOLEAN
			-- Is this value a string?
		do
			Result := True
		end

feature -- Conversion

	as_string: STRING_32
			-- Get string value
		do
			Result := value
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			if is_literal then
				Result := "'" + value + "'"
			else
				Result := "%"" + escape_string (value) + "%""
			end
		end

feature {NONE} -- Implementation

	escape_string (a_string: STRING_32): STRING_32
			-- Escape special characters for basic string
		require
			string_not_void: a_string /= Void
		local
			i: INTEGER
			c: CHARACTER_32
		do
			create Result.make (a_string.count)
			from
				i := 1
			until
				i > a_string.count
			loop
				c := a_string [i]
				inspect c
				when '%B' then
					Result.append ("\b")
				when '%T' then
					Result.append ("\t")
				when '%N' then
					Result.append ("\n")
				when '%F' then
					Result.append ("\f")
				when '%R' then
					Result.append ("\r")
				when '"' then
					Result.append ("\%"")
				when '\' then
					Result.append ("\\")
				else
					if c.natural_32_code < 32 or c.natural_32_code > 126 then
						-- Unicode escape
						Result.append ("\u")
						Result.append (c.natural_32_code.to_hex_string)
					else
						Result.append_character (c)
					end
				end
				i := i + 1
			end
		ensure
			result_not_void: Result /= Void
		end

invariant
	value_not_void: value /= Void

end
