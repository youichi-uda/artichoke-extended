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
