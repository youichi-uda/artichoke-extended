# frozen_string_literal: true

def spec
  time_strftime_utf8
  time_strftime_binary
  time_strftime_empty_warning_verbose
  expect_failure_if_artichoke(RuntimeError, /Unexpected warning emitted when verbose mode off, got: /) do
    # Artichoke does not support the `$VERBOSE` global variable.
    # Warnings are unconditionally printed to `$stderr`.
    time_strftime_empty_warning
  end

  time_initialize
  time_hash
  time_utc_offset
  time_timezone
  time_to_a
  time_localtime_getlocal
  time_round
end

########################################
# Time.new / Time#initialize
########################################

def time_initialize
  # `Time.new` with no arguments is equivalent to `Time.now`.
  t = Time.new
  raise "Expected Time instance, got #{t.class}" unless t.is_a?(Time)

  # Year only.
  t = Time.new(2026)
  raise "Expected year 2026, got #{t.year}" unless t.year == 2026
  raise "Expected month 1, got #{t.month}" unless t.month == 1
  raise "Expected day 1, got #{t.day}" unless t.day == 1
  raise "Expected hour 0, got #{t.hour}" unless t.hour == 0
  raise "Expected min 0, got #{t.min}" unless t.min == 0
  raise "Expected sec 0, got #{t.sec}" unless t.sec == 0

  # Year + month.
  t = Time.new(2026, 4)
  raise "Expected month 4, got #{t.month}" unless t.month == 4

  # Year + month + day.
  t = Time.new(2026, 4, 15)
  raise "Expected 2026-04-15, got #{t.year}-#{t.month}-#{t.day}" unless t.year == 2026 && t.month == 4 && t.day == 15

  # Year through hour.
  t = Time.new(2026, 4, 15, 12)
  raise "Expected hour 12, got #{t.hour}" unless t.hour == 12

  # Year through minute.
  t = Time.new(2026, 4, 15, 12, 30)
  raise "Expected 12:30, got #{t.hour}:#{t.min}" unless t.hour == 12 && t.min == 30

  # Year through second.
  t = Time.new(2026, 4, 15, 12, 30, 45)
  raise "Expected 12:30:45, got #{t.hour}:#{t.min}:#{t.sec}" unless t.hour == 12 && t.min == 30 && t.sec == 45

  # Invalid component values should raise ArgumentError (not NotImplementedError).
  raised = false
  begin
    Time.new(2026, 13, 1) # invalid month
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for month 13' unless raised

  raised = false
  begin
    Time.new(2026, 1, 32) # invalid day
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for day 32' unless raised
end

########################################
# Time#hash
########################################

def time_hash
  # Same instant → same hash.
  t1 = Time.utc(2026, 4, 15, 12, 0, 0)
  t2 = Time.utc(2026, 4, 15, 12, 0, 0)
  raise 'Expected equal hashes for equal Times' unless t1.hash == t2.hash

  # `hash` returns an Integer.
  raise "Expected Integer, got #{t1.hash.class}" unless t1.hash.is_a?(Integer)

  # Different instants → hashes are (overwhelmingly) different.
  t3 = Time.utc(2026, 4, 15, 12, 0, 1)
  raise 'Expected distinct hashes for distinct Times' unless t1.hash != t3.hash

  # Time can be used as a Hash key now.
  table = { t1 => 'a' }
  raise 'Expected table[t2] == "a" (Hash lookup by Time key)' unless table[t2] == 'a'
end

########################################
# Time#utc_offset
########################################

def time_utc_offset
  t = Time.utc(2026, 4, 15)
  raise "Expected 0 for UTC time, got #{t.utc_offset.inspect}" unless t.utc_offset == 0

  # `gmt_offset` is an alias in CRuby; skip if not defined.
  raise 'Expected utc_offset to be Integer' unless t.utc_offset.is_a?(Integer)
end

########################################
# Time#timezone
########################################

def time_timezone
  t = Time.utc(2026, 4, 15)
  zone = t.zone
  raise "Expected zone to be a String, got #{zone.class}" unless zone.is_a?(String)
  raise "Expected UTC time zone to be 'UTC', got #{zone.inspect}" unless zone == 'UTC'
end

########################################
# Time#to_a
########################################

def time_to_a
  t = Time.utc(2026, 4, 15, 12, 34, 56)
  arr = t.to_a
  raise "Expected Array, got #{arr.class}" unless arr.is_a?(Array)
  raise "Expected 10 elements, got #{arr.length}" unless arr.length == 10

  # [sec, min, hour, mday, month, year, wday, yday, isdst, zone]
  raise "Expected sec 56, got #{arr[0].inspect}" unless arr[0] == 56
  raise "Expected min 34, got #{arr[1].inspect}" unless arr[1] == 34
  raise "Expected hour 12, got #{arr[2].inspect}" unless arr[2] == 12
  raise "Expected mday 15, got #{arr[3].inspect}" unless arr[3] == 15
  raise "Expected month 4, got #{arr[4].inspect}" unless arr[4] == 4
  raise "Expected year 2026, got #{arr[5].inspect}" unless arr[5] == 2026

  # wday is 0..6 (Sunday = 0). 2026-04-15 is a Wednesday → 3.
  raise "Expected wday 3 (Wed), got #{arr[6].inspect}" unless arr[6] == 3
  # yday is day-of-year; 2026 is not a leap year, April 15 = 31+28+31+15 = 105
  raise "Expected yday 105, got #{arr[7].inspect}" unless arr[7] == 105

  raise 'Expected isdst to be Boolean' unless arr[8].equal?(true) || arr[8].equal?(false)

  raise "Expected zone to be 'UTC', got #{arr[9].inspect}" unless arr[9] == 'UTC'
end

########################################
# Time#localtime / Time#getlocal
########################################

def time_localtime_getlocal
  # Create a UTC time, then get a local copy. The instant should be
  # the same (to_i), but is_utc should differ (unless the host tz IS
  # UTC).
  t = Time.utc(2026, 4, 16, 12, 0, 0)
  raise 'Expected UTC time to be utc?' unless t.utc?

  local = t.getlocal
  raise "Expected same instant, got utc=#{t.to_i}, local=#{local.to_i}" unless t.to_i == local.to_i
  raise 'Expected getlocal to be a new object' if local.equal?(t)

  # `localtime` mutates in place and returns self.
  t2 = Time.utc(2026, 4, 16, 12, 0, 0)
  result = t2.localtime
  raise 'Expected localtime to return self' unless result.equal?(t2)
  raise "Expected same instant after localtime, got #{t2.to_i}" unless t2.to_i == local.to_i
end

########################################
# Time#round
########################################

def time_round
  # Time.utc has 0 subseconds, so round is a no-op.
  t = Time.utc(2026, 4, 16, 12, 30, 45)
  r = t.round
  raise "Expected sec 45, got #{r.sec}" unless r.sec == 45
  raise 'Expected round to return a new object' if r.equal?(t)

  # Round to 0 digits (default) should keep the second intact for
  # whole-second times.
  raise "Expected same instant, got #{t.to_i} vs #{r.to_i}" unless t.to_i == r.to_i

  # Negative ndigits raises ArgumentError.
  raised = false
  begin
    t.round(-1)
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for negative ndigits' unless raised
end

##
# Runs the given block. Behavior depends on whether we're in Artichoke:
#
# - If `RUBY_ENGINE.start_with?('artichoke')`:
#   * Expect a specific error class and message.
#   * If no error is raised, fail.
#   * If an error is raised that doesn't match `error_class` or `error_message`, fail.
#   * Otherwise pass.
#
# - If not Artichoke:
#   * Expect no error.
#   * If an error is raised, re-raise it.
#
def expect_failure_if_artichoke(error_class, error_message)
  is_artichoke = RUBY_ENGINE.start_with?('artichoke')

  begin
    yield
    # If we get here, no error was raised
    if is_artichoke
      raise "Expected #{error_class} with message #{error_message.inspect} on Artichoke, but no error was raised!"
    end
  rescue error_class => e
    # If we catch the expected error type
    raise "Did not expect any error on non-Artichoke! (Got #{error_class}: #{e.message.inspect})" unless is_artichoke

    case error_message
    when Regexp
      unless e.message =~ error_message
        raise "Unexpected error message: #{e.message.inspect}\nExpected: #{error_message.inspect}"
      end
    when String
      unless e.message == error_message
        raise "Unexpected error message: #{e.message.inspect}\nExpected: #{error_message.inspect}"
      end
    else
      raise "Invalid error_message type: #{error_message.class}. Expected String or Regexp."
    end
    # If message matches, we pass
  end
end

def time_strftime_utf8
  t = Time.at(1000, 0, in: 'Z')

  raise unless t.strftime('%c') == 'Thu Jan  1 00:16:40 1970'
  raise unless "%c \xEF".valid_encoding? == false
  raise unless t.strftime("%c \xEF") == "Thu Jan  1 00:16:40 1970 \xEF"
  raise unless t.strftime("%c \xEF").valid_encoding? == false
  raise unless t.strftime("%c \u{1F600}") == 'Thu Jan  1 00:16:40 1970 😀'
  raise unless t.strftime("%c \u{1F600}").length == 26
  raise unless t.strftime('%c 😀') == 'Thu Jan  1 00:16:40 1970 😀'
  raise unless t.strftime('%c 😀').length == 26
end

def time_strftime_binary
  t = Time.at(1000, 0, in: 'Z')

  raise unless t.strftime('%c'.b) == 'Thu Jan  1 00:16:40 1970'
  raise unless "%c \xEF".b.valid_encoding?
  raise unless t.strftime("%c \xEF".b) == "Thu Jan  1 00:16:40 1970 \xEF".b
  raise unless t.strftime("%c \xEF".b).valid_encoding?
  raise unless t.strftime("%c \u{1F600}".b) == "Thu Jan  1 00:16:40 1970 \xF0\x9F\x98\x80".b
  raise unless t.strftime("%c \u{1F600}".b).length == 29
  raise unless t.strftime('%c 😀'.b) == "Thu Jan  1 00:16:40 1970 \xF0\x9F\x98\x80".b
  raise unless t.strftime('%c 😀'.b).length == 29
end

def time_strftime_empty_warning_verbose
  original_verbose = $VERBOSE
  original_stderr = $stderr

  captured_warnings = []
  fake_stderr = Object.new
  fake_stderr.define_singleton_method(:write) { |msg| captured_warnings << msg }

  begin
    $VERBOSE = true
    $stderr = fake_stderr

    Time.now.strftime('')

    unless captured_warnings.any? { |message| message.end_with?("strftime called with empty format string\n") }
      raise "Expected warning was not emitted, got: #{captured_warnings.inspect}"
    end
  ensure
    $VERBOSE = original_verbose
    $stderr = original_stderr
  end
end

def time_strftime_empty_warning
  original_verbose = $VERBOSE
  original_stderr = $stderr

  captured_warnings = []
  fake_stderr = Object.new
  fake_stderr.define_singleton_method(:write) { |msg| captured_warnings << msg }

  begin
    $VERBOSE = false
    $stderr = fake_stderr

    Time.now.strftime('')

    unless captured_warnings.empty?
      raise "Unexpected warning emitted when verbose mode off, got: #{captured_warnings.inspect}"
    end
  ensure
    $VERBOSE = original_verbose
    $stderr = original_stderr
  end
end

if $PROGRAM_NAME == __FILE__
  result = spec
  puts "All Time functional tests passed: #{result}"
end
