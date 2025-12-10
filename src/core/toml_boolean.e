note
	description: "[
		TOML boolean value.
		Only 'true' and 'false' (lowercase) are valid.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_BOOLEAN

inherit
	TOML_VALUE
		redefine
			is_boolean,
			as_boolean,
			to_toml
		end

create
	make

feature {NONE} -- Initialization

	make (a_value: BOOLEAN)
			-- Create a boolean value
		do
			value := a_value
		ensure
			value_set: value = a_value
		end

feature -- Access

	value: BOOLEAN
			-- The boolean value

feature -- Type checking

	is_boolean: BOOLEAN
			-- Is this value a boolean?
		do
			Result := True
		end

feature -- Conversion

	as_boolean: BOOLEAN
			-- Get boolean value
		do
			Result := value
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			if value then
				Result := "true"
			else
				Result := "false"
			end
		end

end
