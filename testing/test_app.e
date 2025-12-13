note
	description: "Test application for SIMPLE_TOML"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_TOML tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests
			run_test (agent lib_tests.test_parse_simple_table, "test_parse_simple_table")
			run_test (agent lib_tests.test_parse_string_value, "test_parse_string_value")
			run_test (agent lib_tests.test_parse_integer_value, "test_parse_integer_value")
			run_test (agent lib_tests.test_parse_boolean_value, "test_parse_boolean_value")
			run_test (agent lib_tests.test_parse_array, "test_parse_array")
			run_test (agent lib_tests.test_parse_nested_table, "test_parse_nested_table")
			run_test (agent lib_tests.test_to_toml_string, "test_to_toml_string")
			run_test (agent lib_tests.test_to_toml_integer, "test_to_toml_integer")
			run_test (agent lib_tests.test_to_toml_boolean, "test_to_toml_boolean")
			run_test (agent lib_tests.test_has_errors_initial, "test_has_errors_initial")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
