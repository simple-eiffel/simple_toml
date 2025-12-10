note
	description: "Test application runner for simple_toml"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests
		do
			create toml
			print ("simple_toml test suite%N")
			print ("=====================%N%N")

			run_all_tests
		end

feature -- Access

	toml: SIMPLE_TOML
			-- TOML processor

feature -- Helpers

	assert (a_tag: STRING; a_condition: BOOLEAN)
			-- Check condition and report if false
		do
			if not a_condition then
				print ("ASSERTION FAILED: " + a_tag + "%N")
			end
		end

feature -- Tests

	run_all_tests
			-- Run all test cases
		do
			test_parse_simple_key_value
			test_parse_string_types
			test_parse_numbers
			test_parse_boolean
			test_parse_datetime
			test_parse_array
			test_parse_inline_table
			test_parse_table_header
			test_parse_nested_tables
			test_parse_array_of_tables
			test_write_simple_table
			test_write_nested_table
			test_dotted_keys
			test_multiline_strings
			test_error_handling
			test_ucf_format

			print ("%N=======================%N")
			print ("All tests completed!%N")
		end

	test_parse_simple_key_value
			-- Test simple key = value parsing
		local
			l_result: detachable TOML_TABLE
		do
			print ("Test: parse simple key value... ")

			l_result := toml.parse ("name = %"simple_toml%"%N")

			if attached l_result and then attached l_result.string_item ("name") as l_name then
				assert ("name correct", l_name.same_string ("simple_toml"))
				print ("PASSED%N")
			else
				print ("FAILED%N")
			end
		end

	test_parse_string_types
			-- Test different string types
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse string types... ")

			l_text := "[
				basic = "hello\nworld"
				literal = 'hello\nworld'
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached l_result.string_item ("basic") as l_basic then
					-- Basic strings process escapes
					assert ("basic has newline", l_basic.has ('%N'))
				end
				if attached l_result.string_item ("literal") as l_literal then
					-- Literal strings don't process escapes
					assert ("literal has backslash-n", l_literal.has ('\'))
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_numbers
			-- Test integer and float parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse numbers... ")

			l_text := "[
				int_dec = 42
				int_neg = -17
				int_hex = 0xFF
				int_oct = 0o755
				int_bin = 0b11010110
				float = 3.14
				float_exp = 6.022e23
				inf_val = inf
				nan_val = nan
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				assert ("int_dec", l_result.integer_item ("int_dec") = 42)
				assert ("int_neg", l_result.integer_item ("int_neg") = -17)
				assert ("int_hex", l_result.integer_item ("int_hex") = 255) -- 0xFF = 255
				assert ("int_oct", l_result.integer_item ("int_oct") = 493) -- 0o755 = 493
				assert ("int_bin", l_result.integer_item ("int_bin") = 214) -- 0b11010110 = 214
				assert ("float", (l_result.float_item ("float") - 3.14).abs < 0.001)
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_boolean
			-- Test boolean parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse boolean... ")

			l_text := "[
				enabled = true
				disabled = false
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				assert ("enabled", l_result.boolean_item ("enabled") = True)
				assert ("disabled", l_result.boolean_item ("disabled") = False)
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_datetime
			-- Test datetime parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse datetime... ")

			l_text := "[
				odt = 1979-05-27T07:32:00Z
				ldt = 1979-05-27T07:32:00
				ld = 1979-05-27
				lt = 07:32:00
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached l_result.item ("odt") as l_odt and then l_odt.is_datetime then
					assert ("odt is datetime", True)
				end
				if attached l_result.item ("ld") as l_ld and then l_ld.is_date then
					assert ("ld is date", True)
				end
				if attached l_result.item ("lt") as l_lt and then l_lt.is_time then
					assert ("lt is time", True)
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_array
			-- Test array parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse array... ")

			l_text := "[
				integers = [1, 2, 3]
				strings = ["red", "yellow", "green"]
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached l_result.array_item ("integers") as l_ints then
					assert ("3 integers", l_ints.count = 3)
					assert ("first is 1", l_ints.integer_item (1) = 1)
				end
				if attached l_result.array_item ("strings") as l_strs then
					assert ("3 strings", l_strs.count = 3)
					assert ("first is red", l_strs.string_item (1).same_string ("red"))
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_inline_table
			-- Test inline table parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse inline table... ")

			l_text := "point = { x = 1, y = 2 }%N"

			l_result := toml.parse (l_text)

			if attached l_result and then attached l_result.table_item ("point") as l_point then
				assert ("x is 1", l_point.integer_item ("x") = 1)
				assert ("y is 2", l_point.integer_item ("y") = 2)
				assert ("is inline", l_point.is_inline_table)
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_table_header
			-- Test [table] header parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse table header... ")

			l_text := "[
				[database]
				server = "192.168.1.1"
				port = 5432
			]"

			l_result := toml.parse (l_text)

			if attached l_result and then attached l_result.table_item ("database") as l_db then
				assert ("server", attached l_db.string_item ("server") as s and then s.same_string ("192.168.1.1"))
				assert ("port", l_db.integer_item ("port") = 5432)
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_nested_tables
			-- Test nested table parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse nested tables... ")

			l_text := "[
				[servers]

				[servers.alpha]
				ip = "10.0.0.1"

				[servers.beta]
				ip = "10.0.0.2"
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached toml.string_at (l_result, "servers.alpha.ip") as l_ip then
					assert ("alpha ip", l_ip.same_string ("10.0.0.1"))
				end
				if attached toml.string_at (l_result, "servers.beta.ip") as l_ip then
					assert ("beta ip", l_ip.same_string ("10.0.0.2"))
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_parse_array_of_tables
			-- Test [[array.of.tables]] parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: parse array of tables... ")

			l_text := "[
				[[products]]
				name = "Hammer"
				sku = 738594937

				[[products]]
				name = "Nail"
				sku = 284758393
			]"

			l_result := toml.parse (l_text)

			if attached l_result and then attached l_result.array_item ("products") as l_products then
				assert ("2 products", l_products.count = 2)
				if attached l_products.table_item (1).string_item ("name") as l_name then
					assert ("first is Hammer", l_name.same_string ("Hammer"))
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_write_simple_table
			-- Test writing simple table to TOML
		local
			l_table: TOML_TABLE
			l_output: STRING_32
		do
			print ("Test: write simple table... ")

			l_table := toml.new_table
			l_table := l_table.with_string ("name", "simple_toml")
			l_table := l_table.with_integer ("version", 1)
			l_table := l_table.with_boolean ("active", True)

			l_output := toml.to_toml (l_table)

			assert ("has name", l_output.has_substring ("name = "))
			assert ("has version", l_output.has_substring ("version = 1"))
			assert ("has active", l_output.has_substring ("active = true"))

			print ("PASSED%N")
		end

	test_write_nested_table
			-- Test writing nested tables to TOML
		local
			l_table, l_db: TOML_TABLE
			l_output: STRING_32
		do
			print ("Test: write nested table... ")

			l_db := toml.new_table
			l_db := l_db.with_string ("host", "localhost")
			l_db := l_db.with_integer ("port", 5432)

			l_table := toml.new_table
			l_table := l_table.with_string ("title", "Config")
			l_table := l_table.with_table ("database", l_db)

			l_output := toml.to_toml (l_table)

			assert ("has title", l_output.has_substring ("title = "))
			assert ("has database section", l_output.has_substring ("[database]"))
			assert ("has host", l_output.has_substring ("host = "))

			print ("PASSED%N")
		end

	test_dotted_keys
			-- Test dotted key parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: dotted keys... ")

			l_text := "[
				fruit.apple.color = "red"
				fruit.apple.taste = "sweet"
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached toml.string_at (l_result, "fruit.apple.color") as l_color then
					assert ("color is red", l_color.same_string ("red"))
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_multiline_strings
			-- Test multi-line string parsing
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: multiline strings... ")

			l_text := "[
				bio = """
				Larry is a programmer.
				He writes Eiffel code.
				"""
			]"

			l_result := toml.parse (l_text)

			if attached l_result and then attached l_result.string_item ("bio") as l_bio then
				assert ("has newline", l_bio.has ('%N'))
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

	test_error_handling
			-- Test error reporting
		local
			l_result: detachable TOML_TABLE
		do
			print ("Test: error handling... ")

			l_result := toml.parse ("invalid = = = =%N")

			if l_result = Void and toml.has_errors then
				assert ("has error message", not toml.errors_as_string.is_empty)
				print ("PASSED%N")
			else
				print ("FAILED: should have detected error%N")
			end
		end

	test_ucf_format
			-- Test UCF (Universe Configuration File) format
		local
			l_result: detachable TOML_TABLE
			l_text: STRING_32
		do
			print ("Test: UCF format... ")

			l_text := "[
				# UCF - Universe Configuration File for simple_lsp

				[universe]
				name = "simple_ecosystem"
				version = "1.0"

				[[libraries]]
				name = "simple_json"
				path = "$SIMPLE_JSON"

				[[libraries]]
				name = "simple_toml"
				path = "$SIMPLE_TOML"
			]"

			l_result := toml.parse (l_text)

			if attached l_result then
				if attached toml.string_at (l_result, "universe.name") as l_name then
					assert ("universe name", l_name.same_string ("simple_ecosystem"))
				end
				if attached l_result.array_item ("libraries") as l_libs then
					assert ("2 libraries", l_libs.count = 2)
				end
				print ("PASSED%N")
			else
				print ("FAILED: " + toml.errors_as_string + "%N")
			end
		end

end
