note
	description: "[
		TOML table (mapping) value.
		A table is a collection of key/value pairs.
		Keys are always strings; values can be any TOML type.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_TABLE

inherit
	TOML_VALUE
		redefine
			is_table,
			is_inline_table,
			as_table,
			to_toml,
			to_toml_compact
		end

create
	make,
	make_inline

feature {NONE} -- Initialization

	make
			-- Create an empty table
		do
			create entries.make (10)
			create key_order.make (10)
			is_inline := False
		ensure
			empty: is_empty
			not_inline: not is_inline
		end

	make_inline
			-- Create an empty inline table
		do
			create entries.make (10)
			create key_order.make (10)
			is_inline := True
		ensure
			empty: is_empty
			is_inline_set: is_inline
		end

feature -- Access

	entries: HASH_TABLE [TOML_VALUE, STRING_32]
			-- Table entries

	key_order: ARRAYED_LIST [STRING_32]
			-- Keys in insertion order (for reproducible output)

	count: INTEGER
			-- Number of entries
		do
			Result := entries.count
		ensure
			definition: Result = entries.count
		end

	item (a_key: STRING_32): detachable TOML_VALUE
			-- Value for key, or Void if not found
		require
			key_not_void: a_key /= Void
		do
			Result := entries.item (a_key)
		end

	keys: ARRAYED_LIST [STRING_32]
			-- All keys in insertion order
		do
			Result := key_order.twin
		ensure
			result_not_void: Result /= Void
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is the table empty?
		do
			Result := entries.is_empty
		end

	has (a_key: STRING_32): BOOLEAN
			-- Does table have key?
		require
			key_not_void: a_key /= Void
		do
			Result := entries.has (a_key)
		end

	is_inline: BOOLEAN
			-- Is this an inline table?

feature -- Type checking

	is_table: BOOLEAN
			-- Is this value a table?
		do
			Result := True
		end

	is_inline_table: BOOLEAN
			-- Is this value an inline table?
		do
			Result := is_inline
		end

feature -- Conversion

	as_table: TOML_TABLE
			-- Get table value
		do
			Result := Current
		end

feature -- Element change

	put (a_value: TOML_VALUE; a_key: STRING_32)
			-- Add or replace entry
		require
			value_not_void: a_value /= Void
			key_not_void: a_key /= Void
			key_not_empty: not a_key.is_empty
		do
			if not entries.has (a_key) then
				key_order.extend (a_key)
			end
			entries.force (a_value, a_key)
		ensure
			has_key: has (a_key)
			value_set: item (a_key) = a_value
		end

	remove (a_key: STRING_32)
			-- Remove entry
		require
			key_not_void: a_key /= Void
			has_key: has (a_key)
		do
			entries.remove (a_key)
			key_order.prune_all (a_key)
		ensure
			removed: not has (a_key)
		end

	wipe_out
			-- Remove all entries
		do
			entries.wipe_out
			key_order.wipe_out
		ensure
			empty: is_empty
		end

feature -- Convenience accessors

	string_item (a_key: STRING_32): detachable STRING_32
			-- Get string value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_string then
				Result := l_val.as_string
			end
		end

	integer_item (a_key: STRING_32): INTEGER_64
			-- Get integer value for key (0 if not found or not integer)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_integer then
				Result := l_val.as_integer
			end
		end

	float_item (a_key: STRING_32): REAL_64
			-- Get float value for key (0.0 if not found or not float)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_float then
				Result := l_val.as_float
			end
		end

	boolean_item (a_key: STRING_32): BOOLEAN
			-- Get boolean value for key (False if not found or not boolean)
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_boolean then
				Result := l_val.as_boolean
			end
		end

	table_item (a_key: STRING_32): detachable TOML_TABLE
			-- Get table value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_table then
				Result := l_val.as_table
			end
		end

	array_item (a_key: STRING_32): detachable TOML_ARRAY
			-- Get array value for key
		require
			key_not_void: a_key /= Void
		do
			if attached item (a_key) as l_val and then l_val.is_array then
				Result := l_val.as_array
			end
		end

feature -- Fluent API

	with_string (a_key: STRING_32; a_value: STRING_32): like Current
			-- Add string entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (create {TOML_STRING}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_integer (a_key: STRING_32; a_value: INTEGER_64): like Current
			-- Add integer entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {TOML_INTEGER}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_float (a_key: STRING_32; a_value: REAL_64): like Current
			-- Add float entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {TOML_FLOAT}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_boolean (a_key: STRING_32; a_value: BOOLEAN): like Current
			-- Add boolean entry and return self
		require
			key_not_void: a_key /= Void
		do
			put (create {TOML_BOOLEAN}.make (a_value), a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_table (a_key: STRING_32; a_value: TOML_TABLE): like Current
			-- Add table entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (a_value, a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

	with_array (a_key: STRING_32; a_value: TOML_ARRAY): like Current
			-- Add array entry and return self
		require
			key_not_void: a_key /= Void
			value_not_void: a_value /= Void
		do
			put (a_value, a_key)
			Result := Current
		ensure
			has_key: has (a_key)
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			if is_inline then
				Result := to_toml_compact
			else
				Result := to_toml_full ("")
			end
		end

	to_toml_compact: STRING_32
			-- Convert to compact inline table format
		local
			l_key: STRING_32
			l_first: BOOLEAN
		do
			create Result.make (100)
			Result.append_character ('{')
			l_first := True

			across key_order as ic loop
				l_key := ic
				if not l_first then
					Result.append (", ")
				end
				l_first := False

				Result.append (quote_key (l_key))
				Result.append (" = ")
				if attached item (l_key) as al_l_val then
					Result.append (al_l_val.to_toml_compact)
				end
			end

			Result.append_character ('}')
		end

	to_toml_full (a_prefix: STRING_32): STRING_32
			-- Convert to full TOML format with optional table name prefix
		require
			prefix_not_void: a_prefix /= Void
		local
			l_key, l_full_key: STRING_32
			l_value: TOML_VALUE
			l_sub_tables: ARRAYED_LIST [TUPLE [key: STRING_32; table: TOML_TABLE]]
			l_array_of_tables: ARRAYED_LIST [TUPLE [key: STRING_32; arr: TOML_ARRAY]]
		do
			create Result.make (500)
			create l_sub_tables.make (5)
			create l_array_of_tables.make (5)

			-- First pass: output simple key-value pairs
			across key_order as ic loop
				l_key := ic
				if attached item (l_key) as al_l_val then
					l_value := l_val
					if l_value.is_table and not l_value.is_inline_table then
						-- Collect sub-tables for later
						l_sub_tables.extend ([l_key, l_value.as_table])
					elseif l_value.is_array and then is_array_of_tables (l_value.as_array) then
						-- Collect arrays of tables for later
						l_array_of_tables.extend ([l_key, l_value.as_array])
					else
						-- Output simple value
						Result.append (quote_key (l_key))
						Result.append (" = ")
						Result.append (l_value.to_toml_compact)
						Result.append_character ('%N')
					end
				end
			end

			-- Second pass: output sub-tables with headers
			across l_sub_tables as ic loop
				l_key := ic.key
				if a_prefix.is_empty then
					l_full_key := l_key
				else
					l_full_key := a_prefix + "." + l_key
				end

				Result.append_character ('%N')
				Result.append_character ('[')
				Result.append (l_full_key)
				Result.append_character (']')
				Result.append_character ('%N')
				Result.append (ic.table.to_toml_full (l_full_key))
			end

			-- Third pass: output arrays of tables
			across l_array_of_tables as ic loop
				l_key := ic.key
				if a_prefix.is_empty then
					l_full_key := l_key
				else
					l_full_key := a_prefix + "." + l_key
				end

				across ic.arr.items as arr_ic loop
					if arr_ic.is_table then
						Result.append_character ('%N')
						Result.append ("[[")
						Result.append (l_full_key)
						Result.append ("]]")
						Result.append_character ('%N')
						Result.append (arr_ic.as_table.to_toml_full (l_full_key))
					end
				end
			end
		end

feature {NONE} -- Implementation

	quote_key (a_key: STRING_32): STRING_32
			-- Quote key if necessary
		require
			key_not_void: a_key /= Void
		do
			if needs_quoting (a_key) then
				Result := "%"" + a_key + "%""
			else
				Result := a_key
			end
		ensure
			result_not_void: Result /= Void
		end

	needs_quoting (a_key: STRING_32): BOOLEAN
			-- Does key need to be quoted?
		require
			key_not_void: a_key /= Void
		local
			i: INTEGER
			c: CHARACTER_32
		do
			from
				i := 1
			until
				i > a_key.count or Result
			loop
				c := a_key [i]
				-- Bare keys can only contain: A-Za-z0-9_-
				if not ((c >= 'A' and c <= 'Z') or
					    (c >= 'a' and c <= 'z') or
					    (c >= '0' and c <= '9') or
					    c = '_' or c = '-') then
					Result := True
				end
				i := i + 1
			end
		end

	is_array_of_tables (a_array: TOML_ARRAY): BOOLEAN
			-- Is this an array containing only tables?
		require
			array_not_void: a_array /= Void
		do
			Result := not a_array.is_empty and then
				across a_array.items as ic all ic.is_table and not ic.is_inline_table end
		end

invariant
	entries_not_void: entries /= Void
	key_order_not_void: key_order /= Void
	consistent_count: entries.count = key_order.count

end
