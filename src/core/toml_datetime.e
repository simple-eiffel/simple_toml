note
	description: "[
		TOML datetime value.
		Supports:
		- Offset date-time (RFC 3339): 1979-05-27T07:32:00Z or 1979-05-27T07:32:00-07:00
		- Local date-time: 1979-05-27T07:32:00
		- Local date: 1979-05-27
		- Local time: 07:32:00
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	TOML_DATETIME

inherit
	TOML_VALUE
		redefine
			is_datetime,
			is_date,
			is_time,
			to_toml
		end

create
	make_offset_datetime,
	make_local_datetime,
	make_local_date,
	make_local_time

feature {NONE} -- Initialization

	make_offset_datetime (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER; a_offset_hours, a_offset_minutes: INTEGER)
			-- Create offset date-time value
		require
			valid_year: a_year >= 0
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 60 -- 60 for leap second
			valid_offset_hours: a_offset_hours >= -12 and a_offset_hours <= 14
			valid_offset_minutes: a_offset_minutes >= 0 and a_offset_minutes <= 59
		do
			year := a_year
			month := a_month
			day := a_day
			hour := a_hour
			minute := a_minute
			second := a_second
			offset_hours := a_offset_hours
			offset_minutes := a_offset_minutes
			has_time := True
			has_date := True
			has_offset := True
		ensure
			has_all: has_date and has_time and has_offset
		end

	make_local_datetime (a_year, a_month, a_day, a_hour, a_minute, a_second: INTEGER)
			-- Create local date-time value (no timezone)
		require
			valid_year: a_year >= 0
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 60
		do
			year := a_year
			month := a_month
			day := a_day
			hour := a_hour
			minute := a_minute
			second := a_second
			has_time := True
			has_date := True
			has_offset := False
		ensure
			has_datetime: has_date and has_time
			no_offset: not has_offset
		end

	make_local_date (a_year, a_month, a_day: INTEGER)
			-- Create local date value
		require
			valid_year: a_year >= 0
			valid_month: a_month >= 1 and a_month <= 12
			valid_day: a_day >= 1 and a_day <= 31
		do
			year := a_year
			month := a_month
			day := a_day
			has_date := True
			has_time := False
			has_offset := False
		ensure
			has_date_only: has_date and not has_time
			no_offset: not has_offset
		end

	make_local_time (a_hour, a_minute, a_second: INTEGER)
			-- Create local time value
		require
			valid_hour: a_hour >= 0 and a_hour <= 23
			valid_minute: a_minute >= 0 and a_minute <= 59
			valid_second: a_second >= 0 and a_second <= 60
		do
			hour := a_hour
			minute := a_minute
			second := a_second
			has_time := True
			has_date := False
			has_offset := False
		ensure
			has_time_only: has_time and not has_date
			no_offset: not has_offset
		end

feature -- Access

	year: INTEGER
			-- Year component (for date values)

	month: INTEGER
			-- Month component (1-12)

	day: INTEGER
			-- Day component (1-31)

	hour: INTEGER
			-- Hour component (0-23)

	minute: INTEGER
			-- Minute component (0-59)

	second: INTEGER
			-- Second component (0-60, 60 for leap second)

	nanosecond: INTEGER
			-- Fractional second in nanoseconds

	offset_hours: INTEGER
			-- Timezone offset hours (-12 to +14)

	offset_minutes: INTEGER
			-- Timezone offset minutes (0-59)

	has_date: BOOLEAN
			-- Does this value include a date component?

	has_time: BOOLEAN
			-- Does this value include a time component?

	has_offset: BOOLEAN
			-- Does this value include a timezone offset?

feature -- Type checking

	is_datetime: BOOLEAN
			-- Is this value a datetime?
		do
			Result := has_date and has_time
		end

	is_date: BOOLEAN
			-- Is this value a local date?
		do
			Result := has_date and not has_time
		end

	is_time: BOOLEAN
			-- Is this value a local time?
		do
			Result := has_time and not has_date
		end

feature -- Settings

	set_nanosecond (a_ns: INTEGER)
			-- Set fractional second
		require
			valid_nanosecond: a_ns >= 0 and a_ns < 1_000_000_000
		do
			nanosecond := a_ns
		ensure
			nanosecond_set: nanosecond = a_ns
		end

feature -- Output

	to_toml: STRING_32
			-- Convert to TOML representation
		do
			create Result.make (32)

			if has_date then
				Result.append (format_number (year, 4))
				Result.append_character ('-')
				Result.append (format_number (month, 2))
				Result.append_character ('-')
				Result.append (format_number (day, 2))
			end

			if has_date and has_time then
				Result.append_character ('T')
			end

			if has_time then
				Result.append (format_number (hour, 2))
				Result.append_character (':')
				Result.append (format_number (minute, 2))
				Result.append_character (':')
				Result.append (format_number (second, 2))

				if nanosecond > 0 then
					Result.append_character ('.')
					Result.append (format_nanosecond)
				end
			end

			if has_offset then
				if offset_hours = 0 and offset_minutes = 0 then
					Result.append_character ('Z')
				else
					if offset_hours >= 0 then
						Result.append_character ('+')
					else
						Result.append_character ('-')
					end
					Result.append (format_number (offset_hours.abs, 2))
					Result.append_character (':')
					Result.append (format_number (offset_minutes, 2))
				end
			end
		end

feature {NONE} -- Implementation

	format_number (a_value: INTEGER; a_width: INTEGER): STRING_32
			-- Format number with leading zeros
		require
			positive_value: a_value >= 0
			positive_width: a_width > 0
		do
			Result := a_value.out
			from
			until
				Result.count >= a_width
			loop
				Result.prepend_character ('0')
			end
		ensure
			correct_width: Result.count >= a_width
		end

	format_nanosecond: STRING_32
			-- Format nanosecond, trimming trailing zeros
		local
			l_str: STRING_32
		do
			l_str := format_number (nanosecond, 9)
			-- Trim trailing zeros but keep at least one digit
			from
			until
				l_str.count <= 1 or else l_str [l_str.count] /= '0'
			loop
				l_str.remove_tail (1)
			end
			Result := l_str
		ensure
			result_not_void: Result /= Void
			at_least_one_digit: Result.count >= 1
		end

end
