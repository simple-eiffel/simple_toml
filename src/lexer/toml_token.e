note
	description: "[
		Token produced by TOML lexer.
		Represents a single lexical element in TOML source.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_TOKEN

create
	make

feature {NONE} -- Initialization

	make (a_type: INTEGER; a_value: STRING_32; a_line, a_column: INTEGER)
			-- Create a token
		require
			value_not_void: a_value /= Void
			valid_line: a_line >= 1
			valid_column: a_column >= 1
		do
			type := a_type
			value := a_value
			line := a_line
			column := a_column
		ensure
			type_set: type = a_type
			value_set: value = a_value
			line_set: line = a_line
			column_set: column = a_column
		end

feature -- Access

	type: INTEGER
			-- Token type (see Token_* constants)

	value: STRING_32
			-- Token value/text

	line: INTEGER
			-- Line number (1-based)

	column: INTEGER
			-- Column number (1-based)

feature -- Status report

	is_eof: BOOLEAN
			-- Is this the end-of-file token?
		do
			Result := type = Token_eof
		end

	is_error: BOOLEAN
			-- Is this an error token?
		do
			Result := type = Token_error
		end

feature -- Output

	debug_output: STRING
			-- String representation for debugging
		do
			Result := token_type_name (type) + ": %"" + value.to_string_8 + "%" at " + line.out + ":" + column.out
		end

feature {NONE} -- Implementation

	token_type_name (a_type: INTEGER): STRING
			-- Name for token type
		do
			inspect a_type
			when Token_eof then Result := "EOF"
			when Token_error then Result := "ERROR"
			when Token_newline then Result := "NEWLINE"
			when Token_equals then Result := "EQUALS"
			when Token_dot then Result := "DOT"
			when Token_comma then Result := "COMMA"
			when Token_lbracket then Result := "LBRACKET"
			when Token_rbracket then Result := "RBRACKET"
			when Token_lbrace then Result := "LBRACE"
			when Token_rbrace then Result := "RBRACE"
			when Token_double_lbracket then Result := "DOUBLE_LBRACKET"
			when Token_double_rbracket then Result := "DOUBLE_RBRACKET"
			when Token_bare_key then Result := "BARE_KEY"
			when Token_basic_string then Result := "BASIC_STRING"
			when Token_literal_string then Result := "LITERAL_STRING"
			when Token_ml_basic_string then Result := "ML_BASIC_STRING"
			when Token_ml_literal_string then Result := "ML_LITERAL_STRING"
			when Token_integer then Result := "INTEGER"
			when Token_float then Result := "FLOAT"
			when Token_boolean then Result := "BOOLEAN"
			when Token_datetime then Result := "DATETIME"
			else
				Result := "UNKNOWN(" + a_type.out + ")"
			end
		end

feature -- Token type constants

	Token_eof: INTEGER = 0
	Token_error: INTEGER = 1
	Token_newline: INTEGER = 2
	Token_equals: INTEGER = 3
	Token_dot: INTEGER = 4
	Token_comma: INTEGER = 5
	Token_lbracket: INTEGER = 6
	Token_rbracket: INTEGER = 7
	Token_lbrace: INTEGER = 8
	Token_rbrace: INTEGER = 9
	Token_double_lbracket: INTEGER = 10
	Token_double_rbracket: INTEGER = 11
	Token_bare_key: INTEGER = 12
	Token_basic_string: INTEGER = 13
	Token_literal_string: INTEGER = 14
	Token_ml_basic_string: INTEGER = 15
	Token_ml_literal_string: INTEGER = 16
	Token_integer: INTEGER = 17
	Token_float: INTEGER = 18
	Token_boolean: INTEGER = 19
	Token_datetime: INTEGER = 20

invariant
	value_not_void: value /= Void
	valid_line: line >= 1
	valid_column: column >= 1

end
