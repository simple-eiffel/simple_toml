note
	description: "Tests for SIMPLE_TOML"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Parsing

	test_parse_simple_table
			-- Test parsing simple TOML table.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("name = %"Alice%"%Nage = 30")
			assert_attached ("parsed", table)
			if attached table then
				assert_strings_equal ("name", "Alice", table.string_item ("name"))
				assert_integers_equal ("age", 30, table.integer_item ("age"))
			end
		end

	test_parse_string_value
			-- Test parsing TOML string.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("message = %"hello world%"")
			if attached table then
				assert_strings_equal ("string value", "hello world", table.string_item ("message"))
			else
				assert_true ("parsed", False)
			end
		end

	test_parse_integer_value
			-- Test parsing TOML integer.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("count = 42")
			if attached table then
				assert_integers_equal ("integer value", 42, table.integer_item ("count"))
			else
				assert_true ("parsed", False)
			end
		end

	test_parse_boolean_value
			-- Test parsing TOML boolean.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("enabled = true")
			if attached table then
				assert_true ("boolean value", table.boolean_item ("enabled"))
			else
				assert_true ("parsed", False)
			end
		end

	test_parse_array
			-- Test parsing TOML array.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("items = [1, 2, 3]")
			if attached table and then attached table.array_item ("items") as arr then
				assert_integers_equal ("array count", 3, arr.count)
			else
				assert_true ("parsed", False)
			end
		end

	test_parse_nested_table
			-- Test parsing nested TOML table.
		note
			testing: "covers/{SIMPLE_TOML}.parse"
		local
			toml: SIMPLE_TOML
			table: TOML_TABLE
		do
			create toml
			table := toml.parse ("[server]%Nhost = %"localhost%"%Nport = 8080")
			if attached table and then attached table.table_item ("server") as server then
				assert_strings_equal ("host", "localhost", server.string_item ("host"))
				assert_integers_equal ("port", 8080, server.integer_item ("port"))
			else
				assert_true ("parsed", False)
			end
		end

feature -- Test: Generation

	test_to_toml_string
			-- Test generating TOML from string value.
		note
			testing: "covers/{TOML_STRING}.to_toml"
		local
			str: TOML_STRING
		do
			create str.make ("hello")
			assert_strings_equal ("toml string", "%"hello%"", str.to_toml)
		end

	test_to_toml_integer
			-- Test generating TOML from integer value.
		note
			testing: "covers/{TOML_INTEGER}.to_toml"
		local
			int: TOML_INTEGER
		do
			create int.make (42)
			assert_strings_equal ("toml integer", "42", int.to_toml)
		end

	test_to_toml_boolean
			-- Test generating TOML from boolean value.
		note
			testing: "covers/{TOML_BOOLEAN}.to_toml"
		local
			bool: TOML_BOOLEAN
		do
			create bool.make (True)
			assert_strings_equal ("toml true", "true", bool.to_toml)
			create bool.make (False)
			assert_strings_equal ("toml false", "false", bool.to_toml)
		end

feature -- Test: Error Handling

	test_has_errors_initial
			-- Test no errors initially.
		note
			testing: "covers/{SIMPLE_TOML}.has_errors"
		local
			toml: SIMPLE_TOML
		do
			create toml
			assert_false ("no initial errors", toml.has_errors)
		end

end
