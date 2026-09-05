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

	test_load_file_utf_8
			-- A file's non-ASCII values arrive as code points, not as
			-- per-byte mojibake (TOML files are UTF-8 by specification).
		local
			t: SIMPLE_TOML
			f: PLAIN_TEXT_FILE
			l_path: STRING_32
			l_bytes: STRING_8
		do
			create t
			l_path := {STRING_32} "testing/utf8_probe.toml"
			l_bytes := "name = %"caf"
			l_bytes.append_code (195)
			l_bytes.append_code (169)
			l_bytes.append_code (32)
			l_bytes.append_code (215)
			l_bytes.append_code (169)
			l_bytes.append ("%"%N")
			create f.make_open_write (l_path)
			f.put_string (l_bytes)
			f.close
			if attached t.load_file (l_path) as l_table and then attached l_table.string_item ({STRING_32} "name") as l_name then
					-- "caf" + e-acute + space + shin: six code points.
				assert ("six code points", l_name.count = 6)
				assert ("e acute decoded", l_name.code (4) = 233)
				assert ("hebrew shin decoded", l_name.code (6) = 1513)
			else
				assert ("utf-8 file parses with the key present", False)
			end
			create f.make_with_name (l_path)
			if f.exists then
				f.delete
			end
		end

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
			if attached table and then attached table.string_item ("name") as l_name then
				assert_strings_equal ("name", "Alice", l_name)
				assert_integers_equal ("age", 30, table.integer_item ("age").as_integer_32)
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
			if attached table and then attached table.string_item ("message") as l_msg then
				assert_strings_equal ("string value", "hello world", l_msg)
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
				assert_integers_equal ("integer value", 42, table.integer_item ("count").as_integer_32)
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
			if attached table and then attached table.table_item ("server") as server and then attached server.string_item ("host") as l_host then
				assert_strings_equal ("host", "localhost", l_host)
				assert_integers_equal ("port", 8080, server.integer_item ("port").as_integer_32)
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

	test_to_toml_literal_keeps_non_ascii
			-- A literal string's `to_toml' hands back the value's own code points.
			-- The two quote manifests used to be STRING_8, which sent the STRING_32
			-- value through the obsolete `as_string_8' and replaced every non-ASCII
			-- code point with a null character.
		note
			testing: "covers/{TOML_STRING}.to_toml"
		local
			l_value: STRING_32
			l_string: TOML_STRING
			l_out: STRING_32
		do
			create l_value.make (3)
			l_value.append_code (233)
			l_value.append_code (1513)
			l_value.append_code (955)
			create l_string.make_literal (l_value)
			l_out := l_string.to_toml
				-- Quote + e-acute + Hebrew shin + Greek lambda + quote: five code points.
			assert ("five code points", l_out.count = 5)
			assert ("opening quote", l_out.code (1) = 39)
			assert ("e acute survives", l_out.code (2) = 233)
			assert ("hebrew shin survives", l_out.code (3) = 1513)
			assert ("greek lambda survives", l_out.code (4) = 955)
			assert ("closing quote", l_out.code (5) = 39)
		end

	test_to_toml_ascii_unchanged
			-- Widening the manifests leaves ASCII output what it was, character for
			-- character: the quotes around a basic and a literal string, and the
			-- 0o and 0b prefixes on the two radix integer formats.
		note
			testing: "covers/{TOML_STRING}.to_toml", "covers/{TOML_INTEGER}.to_toml"
		local
			l_basic, l_literal: TOML_STRING
			l_integer: TOML_INTEGER
		do
			create l_basic.make ({STRING_32} "a")
			assert_strings_equal ("basic quotes", "%"a%"", l_basic.to_toml)
			create l_literal.make_literal ({STRING_32} "a")
			assert_strings_equal ("literal quotes", "'a'", l_literal.to_toml)
			create l_integer.make_octal (8)
			assert_strings_equal ("octal prefix", "0o10", l_integer.to_toml)
			create l_integer.make_binary (5)
			assert_strings_equal ("binary prefix", "0b101", l_integer.to_toml)
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
