note
	description: "[
		TOML array value.
		Arrays must contain values of the same type (homogeneous).
		Supports nested arrays and tables.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_ARRAY

inherit
	TOML_VALUE
		redefine
			is_array,
			as_array,
			to_toml,
			to_toml_compact
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create an empty array
		do
			create items.make (10)
		ensure
			empty: is_empty
		end

feature -- Access

	items: ARRAYED_LIST [TOML_VALUE]
			-- Array elements

	count: INTEGER
			-- Number of elements
		do
			Result := items.count
		ensure
			definition: Result = items.count
		end

	item (a_index: INTEGER): TOML_VALUE
			-- Element at index (1-based)
		require
			valid_index: valid_index (a_index)
		do
			Result := items [a_index]
		end

	first: TOML_VALUE
			-- First element
		require
			not_empty: not is_empty
		do
			Result := items.first
		end

	last: TOML_VALUE
			-- Last element
		require
			not_empty: not is_empty
		do
			Result := items.last
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is the array empty?
		do
			Result := items.is_empty
		end

	valid_index (a_index: INTEGER): BOOLEAN
			-- Is `a_index` a valid index?
		do
			Result := a_index >= 1 and a_index <= count
		end

feature -- Type checking

	is_array: BOOLEAN
			-- Is this value an array?
		do
			Result := True
		end

feature -- Conversion

	as_array: TOML_ARRAY
			-- Get array value
		do
			Result := Current
		end

feature -- Element change

	extend (a_value: TOML_VALUE)
			-- Add element to end of array
		require
			value_not_void: a_value /= Void
		do
			items.extend (a_value)
		ensure
			one_more: count = old count + 1
			last_is_value: last = a_value
		end

	put (a_value: TOML_VALUE; a_index: INTEGER)
			-- Replace element at index
		require
			value_not_void: a_value /= Void
			valid_index: valid_index (a_index)
		do
			items [a_index] := a_value
		ensure
			replaced: item (a_index) = a_value
			same_count: count = old count
		end

	remove (a_index: INTEGER)
			-- Remove element at index
		require
			valid_index: valid_index (a_index)
		do
			items.go_i_th (a_index)
			items.remove
		ensure
			one_less: count = old count - 1
		end

	wipe_out
			-- Remove all elements
		do
			items.wipe_out
		ensure
			empty: is_empty
		end

feature -- Convenience accessors

	string_item (a_index: INTEGER): STRING_32
			-- Get string at index
		require
			valid_index: valid_index (a_index)
			is_string: item (a_index).is_string
		do
			Result := item (a_index).as_string
		end

	integer_item (a_index: INTEGER): INTEGER_64
			-- Get integer at index
		require
			valid_index: valid_index (a_index)
			is_integer: item (a_index).is_integer
		do
			Result := item (a_index).as_integer
		end

	float_item (a_index: INTEGER): REAL_64
			-- Get float at index
		require
			valid_index: valid_index (a_index)
			is_float: item (a_index).is_float
		do
			Result := item (a_index).as_float
		end

	boolean_item (a_index: INTEGER): BOOLEAN
			-- Get boolean at index
		require
			valid_index: valid_index (a_index)
			is_boolean: item (a_index).is_boolean
		do
			Result := item (a_index).as_boolean
		end

	table_item (a_index: INTEGER): TOML_TABLE
			-- Get table at index
		require
			valid_index: valid_index (a_index)
			is_table: item (a_index).is_table
		do
			Result := item (a_index).as_table
		end

	array_item (a_index: INTEGER): TOML_ARRAY
			-- Get array at index
		require
			valid_index: valid_index (a_index)
			is_array: item (a_index).is_array
		do
			Result := item (a_index).as_array
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation (multi-line for readability)
		local
			i: INTEGER
		do
			create Result.make (100)
			Result.append_character ('[')

			if not is_empty then
				Result.append_character ('%N')
				from
					i := 1
				until
					i > count
				loop
					Result.append ("  ")
					Result.append (item (i).to_toml)
					if i < count then
						Result.append_character (',')
					end
					Result.append_character ('%N')
					i := i + 1
				end
			end

			Result.append_character (']')
		end

	to_toml_compact: STRING_32
			-- Convert to compact TOML (single line)
		local
			i: INTEGER
		do
			create Result.make (100)
			Result.append_character ('[')

			from
				i := 1
			until
				i > count
			loop
				if i > 1 then
					Result.append (", ")
				end
				Result.append (item (i).to_toml_compact)
				i := i + 1
			end

			Result.append_character (']')
		end

invariant
	items_not_void: items /= Void

end
