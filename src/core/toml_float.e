note
	description: "[
		TOML float value.
		Supports standard decimal notation, exponent notation, and special values (inf, nan).
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_FLOAT

inherit
	TOML_VALUE
		redefine
			is_float,
			as_float,
			to_toml
		end

create
	make,
	make_infinity,
	make_nan

feature {NONE} -- Initialization

	make (a_value: REAL_64)
			-- Create a float value
		do
			value := a_value
			is_infinity_value := False
			is_nan_value := False
			is_negative_infinity := False
		ensure
			value_set: value = a_value
			not_special: not is_infinity_value and not is_nan_value
		end

	make_infinity (a_negative: BOOLEAN)
			-- Create an infinity value
		do
			if a_negative then
				value := {REAL_64}.negative_infinity
				is_negative_infinity := True
			else
				value := {REAL_64}.positive_infinity
				is_negative_infinity := False
			end
			is_infinity_value := True
			is_nan_value := False
		ensure
			is_infinity: is_infinity_value
			not_nan: not is_nan_value
			negative_set: is_negative_infinity = a_negative
		end

	make_nan
			-- Create a NaN value
		do
			value := {REAL_64}.nan
			is_nan_value := True
			is_infinity_value := False
			is_negative_infinity := False
		ensure
			is_nan: is_nan_value
			not_infinity: not is_infinity_value
		end

feature -- Access

	value: REAL_64
			-- The float value

	is_infinity_value: BOOLEAN
			-- Is this an infinity value?

	is_negative_infinity: BOOLEAN
			-- Is this negative infinity?

	is_nan_value: BOOLEAN
			-- Is this a NaN value?

feature -- Type checking

	is_float: BOOLEAN
			-- Is this value a float?
		do
			Result := True
		end

feature -- Conversion

	as_float: REAL_64
			-- Get float value
		do
			Result := value
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			if is_nan_value then
				Result := "nan"
			elseif is_infinity_value then
				if is_negative_infinity then
					Result := "-inf"
				else
					Result := "inf"
				end
			else
				Result := value.out
				-- Ensure there's a decimal point for TOML compliance
				if not Result.has ('.') and not Result.has ('e') and not Result.has ('E') then
					Result.append (".0")
				end
			end
		end

end
