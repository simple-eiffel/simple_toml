note
	description: "[
		TOML integer value.
		Supports decimal, hexadecimal (0x), octal (0o), and binary (0b) formats.
		Underscores allowed as visual separators.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_INTEGER

inherit
	TOML_VALUE
		redefine
			is_integer,
			as_integer,
			to_toml
		end

create
	make,
	make_hex,
	make_octal,
	make_binary

feature {NONE} -- Initialization

	make (a_value: INTEGER_64)
			-- Create a decimal integer value
		do
			value := a_value
			format := Format_decimal
		ensure
			value_set: value = a_value
			decimal_format: format = Format_decimal
		end

	make_hex (a_value: INTEGER_64)
			-- Create a hexadecimal integer value
		do
			value := a_value
			format := Format_hex
		ensure
			value_set: value = a_value
			hex_format: format = Format_hex
		end

	make_octal (a_value: INTEGER_64)
			-- Create an octal integer value
		do
			value := a_value
			format := Format_octal
		ensure
			value_set: value = a_value
			octal_format: format = Format_octal
		end

	make_binary (a_value: INTEGER_64)
			-- Create a binary integer value
		do
			value := a_value
			format := Format_binary
		ensure
			value_set: value = a_value
			binary_format: format = Format_binary
		end

feature -- Access

	value: INTEGER_64
			-- The integer value

	format: INTEGER
			-- Storage format (decimal, hex, octal, binary)

feature -- Type checking

	is_integer: BOOLEAN
			-- Is this value an integer?
		do
			Result := True
		end

feature -- Conversion

	as_integer: INTEGER_64
			-- Get integer value
		do
			Result := value
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			inspect format
			when Format_hex then
				Result := "0x" + value.to_hex_string
			when Format_octal then
				Result := "0o" + to_octal_string (value)
			when Format_binary then
				Result := "0b" + to_binary_string (value)
			else
				Result := value.out
			end
		end

feature {NONE} -- Implementation

	to_octal_string (a_value: INTEGER_64): STRING_32
			-- Convert value to octal string
		local
			l_val: INTEGER_64
			l_digit: INTEGER
			l_digits: STRING_32
		do
			l_digits := "01234567"
			create Result.make (22)
			l_val := a_value.abs
			if l_val = 0 then
				Result := "0"
			else
				from
				until
					l_val = 0
				loop
					l_digit := (l_val \\ 8).as_integer_32
					Result.prepend_character (l_digits [l_digit + 1])
					l_val := l_val // 8
				end
				if a_value < 0 then
					Result.prepend_character ('-')
				end
			end
		ensure
			result_not_void: Result /= Void
		end

	to_binary_string (a_value: INTEGER_64): STRING_32
			-- Convert value to binary string
		local
			l_val: INTEGER_64
		do
			create Result.make (64)
			l_val := a_value.abs
			if l_val = 0 then
				Result := "0"
			else
				from
				until
					l_val = 0
				loop
					if l_val \\ 2 = 1 then
						Result.prepend_character ('1')
					else
						Result.prepend_character ('0')
					end
					l_val := l_val // 2
				end
				if a_value < 0 then
					Result.prepend_character ('-')
				end
			end
		ensure
			result_not_void: Result /= Void
		end

feature -- Constants

	Format_decimal: INTEGER = 0
	Format_hex: INTEGER = 1
	Format_octal: INTEGER = 2
	Format_binary: INTEGER = 3

end
