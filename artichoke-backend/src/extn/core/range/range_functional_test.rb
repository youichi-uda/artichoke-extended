# frozen_string_literal: true

def spec
  range_size_succ
end

########################################
# Range#size (succ-based)
########################################

def range_size_succ
  # Single-character inclusive String range.
  raise "Expected 26, got #{('a'..'z').size}" unless ('a'..'z').size == 26

  # Exclusive String range drops the endpoint.
  raise "Expected 25, got #{('a'...'z').size}" unless ('a'...'z').size == 25

  # Degenerate: start == end, inclusive → 1.
  raise "Expected 1, got #{('a'..'a').size}" unless ('a'..'a').size == 1

  # Degenerate: start == end, exclusive → 0.
  raise "Expected 0, got #{('a'...'a').size}" unless ('a'...'a').size == 0

  # Reversed (start > end) → 0 elements.
  raise "Expected 0, got #{('z'..'a').size}" unless ('z'..'a').size == 0

  # Two-character Strings using the carry behaviour of `String#succ`.
  # 'aa'..'ba' iterates 'aa', 'ab', ..., 'az', 'ba' → 27 values.
  raise "Expected 27, got #{('aa'..'ba').size}" unless ('aa'..'ba').size == 27

  # Numeric ranges still go through the Integer branch and are
  # unaffected by this change.
  raise "Expected 10, got #{(1..10).size}" unless (1..10).size == 10
  raise "Expected 9, got #{(1...10).size}" unless (1...10).size == 9
end

spec if $PROGRAM_NAME == __FILE__
