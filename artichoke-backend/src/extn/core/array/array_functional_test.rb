# frozen_string_literal: true

def spec
  empty_get
  inline_get
  dynamic_get

  empty_slice
  inline_slice
  dynamic_slice

  inline_set
  inline_set_sparse
  dynamic_set
  dynamic_set_sparse

  inline_set_with_drain
  dynamic_set_with_drain

  inline_set_slice
  dynamic_set_slice

  push

  concat

  inline_pop
  dynamic_pop

  reverse

  max
  min
  zip
  product
  sample
  repeated_combination
  repeated_permutation
end

def empty_get
  a = []
  raise unless a[0].nil?
  raise unless a[100].nil?
  raise unless a[-1].nil?
  raise unless a[-100].nil?
end

def inline_get
  a = [1, 2, 3]
  raise unless a[0] == 1
  raise unless a[100].nil?
  raise unless a[-1] == 3
  raise unless a[-100].nil?
end

def dynamic_get
  a = (1..25).map.to_a
  raise unless a[0] == 1
  raise unless a[10] == 11
  raise unless a[100].nil?
  raise unless a[-1] == 25
  raise unless a[-100].nil?
end

def empty_slice
  a = []
  raise unless a[0, 0] == []
  raise unless a[1, 10].nil?
end

def inline_slice
  a = [1, 2, 3]
  raise unless a[0, 0] == []
  raise unless a[1, 10] == [2, 3]
  raise unless a[10, 5].nil?
end

def dynamic_slice
  a = (1..25).map.to_a
  raise unless a[0, 0] == []
  raise unless a[1, 10] == [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  raise unless a[10, 5] == [11, 12, 13, 14, 15]
  raise unless a[22, 10] == [23, 24, 25]
  raise unless a[100, 10].nil?
end

def inline_set
  a = [1, 2, 3]
  a[0] = 'a'
  raise unless a == ['a', 2, 3]

  a = [1, 2, 3]
  a[1] = 'a'
  raise unless a == [1, 'a', 3]

  a = [1, 2, 3]
  a[-1] = 'a'
  raise unless a == [1, 2, 'a']

  a = [1, 2, 3]
  a[3] = 'a'
  raise unless a == [1, 2, 3, 'a']
end

def inline_set_sparse
  # to inline
  a = [1, 2, 3]
  a[6] = 'a'
  raise unless a == [1, 2, 3, nil, nil, nil, 'a']

  # to dynamic
  a = [1, 2, 3]
  a[20] = 'a'
  raise unless a == [1, 2, 3, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 'a']
end

def dynamic_set
  a = (1..25).map.to_a
  a[0] = 'a'
  raise unless a == ['a', 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[10] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'a', 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[-1] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 'a']

  a = (1..25).map.to_a
  a[25] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 'a']
end

def dynamic_set_sparse
  a = (1..25).map.to_a
  a[30] = 'a'
  unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, nil, nil, nil, nil, nil, 'a']
    raise
  end
end

def inline_set_with_drain
  a = [1, 2, 3]
  a[0, 0] = 'a'
  raise unless a == ['a', 1, 2, 3]

  a = [1, 2, 3]
  a[1, 0] = 'a'
  raise unless a == [1, 'a', 2, 3]

  a = [1, 2, 3]
  a[3, 0] = 'a'
  raise unless a == [1, 2, 3, 'a']

  a = [1, 2, 3]
  a[6, 0] = 'a'
  raise unless a == [1, 2, 3, nil, nil, nil, 'a']

  a = [1, 2, 3]
  a[6, 10] = 'a'
  raise unless a == [1, 2, 3, nil, nil, nil, 'a']

  a = [1, 2, 3]
  a[0, 100] = 'a'
  raise unless a == ['a']

  a = [1, 2, 3]
  a[1, 1] = 'a'
  raise unless a == [1, 'a', 3]

  a = [1, 2, 3]
  a[1, 2] = 'a'
  raise unless a == [1, 'a']

  a = [1, 2, 3]
  a[1, 10] = 'a'
  raise unless a == [1, 'a']

  a = [1, 2, 3]
  a[3, 2] = 'a'
  raise unless a == [1, 2, 3, 'a']

  a = [1, 2, 3, 4, 5, 6, 7, 8]
  a[7, 100] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 'a']
end

def dynamic_set_with_drain
  a = (1..25).map.to_a
  a[0, 0] = 'a'
  raise unless a == ['a', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[1, 0] = 'a'
  raise unless a == [1, 'a', 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[25, 0] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 'a']

  a = (1..25).map.to_a
  a[27, 0] = 'a'
  unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, nil, nil, 'a']
    raise
  end

  a = (1..25).map.to_a
  a[27, 10] = 'a'
  unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, nil, nil, 'a']
    raise
  end

  a = (1..25).map.to_a
  a[0, 100] = 'a'
  raise unless a == ['a']

  a = (1..25).map.to_a
  a[1, 1] = 'a'
  raise unless a == [1, 'a', 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[1, 2] = 'a'
  raise unless a == [1, 'a', 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[1, 24] = 'a'
  raise unless a == [1, 'a']

  a = (1..25).map.to_a
  a[1, 100] = 'a'
  raise unless a == [1, 'a']

  a = (1..25).map.to_a
  a[20, 100] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 'a']

  a = (1..25).map.to_a
  a[25, 100] = 'a'
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 'a']
end

def inline_set_slice
  a = [1, 2, 3]
  a[0, 0] = []
  raise unless a == [1, 2, 3]

  a = [1, 2, 3]
  a[3, 0] = []
  raise unless a == [1, 2, 3]

  a = [1, 2, 3]
  a[5, 0] = []
  raise unless a == [1, 2, 3, nil, nil]

  a = [1, 2, 3]
  a[0, 1] = []
  raise unless a == [2, 3]

  a = [1, 2, 3]
  a[0, 3] = []
  raise unless a == []

  a = [1, 2, 3]
  a[0, 100] = []
  raise unless a == []

  a = [1, 2, 3]
  a[0, 0] = %w[a b c]
  raise unless a == ['a', 'b', 'c', 1, 2, 3]

  a = [1, 2, 3]
  a[0, 1] = %w[a b c]
  raise unless a == ['a', 'b', 'c', 2, 3]

  a = [1, 2, 3]
  a[0, 100] = %w[a b c]
  raise unless a == %w[a b c]

  a = [1, 2, 3]
  a[3, 100] = %w[a b c]
  raise unless a == [1, 2, 3, 'a', 'b', 'c']

  a = [1, 2, 3]
  a[5, 10] = %w[a b c]
  raise unless a == [1, 2, 3, nil, nil, 'a', 'b', 'c']

  a = [1, 2, 3]
  a[5, 10] = %w[a b c d e f g h]
  raise unless a == [1, 2, 3, nil, nil, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

  a = [1, 2, 3]
  a[0, 100] = (1..25).map.to_a
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = [1, 2, 3]
  a[0, 0] = %w[a b c d e]
  raise unless a == ['a', 'b', 'c', 'd', 'e', 1, 2, 3]

  a = [1, 2, 3]
  a[0, 3] = %w[a b c d e f g h]
  raise unless a == %w[a b c d e f g h]
end

def dynamic_set_slice
  a = (1..25).map.to_a
  a[0, 0] = []
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[0, 0] = %w[a]
  raise unless a == ['a', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[0, 0] = %w[a]
  raise unless a == ['a', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]

  a = (1..25).map.to_a
  a[0, 25] = %w[a]
  raise unless a == ['a']
end

def push
  a = [1, 2]
  b = [[3], [4]]
  a.push b
  raise unless a == [1, 2, [[3], [4]]]

  a = [1, 2]
  b = 3
  a.push b
  raise unless a == [1, 2, 3]

  a = [1, 2]
  b = [3, 4]
  a.push b
  raise unless a == [1, 2, [3, 4]]

  a = []
  b = []
  a.push b
  raise unless a == [[]]

  a = []
  b = [1, 2]
  a.push b
  raise unless a == [[1, 2]]
end

def concat
  a = []
  b = []
  a.concat(b)
  raise unless a == []
  raise unless b == []

  a = [1]
  b = []
  a.concat(b)
  raise unless a == [1]
  raise unless b == []

  a = []
  b = %w[a]
  a.concat(b)
  raise unless a == %w[a]
  raise unless b == %w[a]

  a = [1]
  b = %w[a]
  a.concat(b)
  raise unless a == [1, 'a']
  raise unless b == %w[a]

  a = [1, 2, 3, 4, 5, 6, 7, 8]
  b = %w[a]
  a.concat(b)
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 'a']
  raise unless b == %w[a]

  a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  b = %w[a]
  a.concat(b)
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'a']
  raise unless b == %w[a]

  a = [1]
  b = %w[a b c d e f g h]
  a.concat(b)
  raise unless a == [1, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
  raise unless b == %w[a b c d e f g h]

  a = [1]
  b = %w[a b c d e f g h i j]
  a.concat(b)
  raise unless a == [1, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
  raise unless b == %w[a b c d e f g h i j]

  a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  b = %w[a b c d e f g h i j]
  a.concat(b)
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
  raise unless b == %w[a b c d e f g h i j]
end

def inline_pop
  a = []
  r = a.pop
  raise unless r.nil?
  raise unless a == []

  a = [1]
  r = a.pop
  raise unless r == 1
  raise unless a == []

  a = [1, 2, 3]
  r = a.pop
  raise unless r == 3
  raise unless a == [1, 2]

  a = [1, 2, 3, 4, 5, 6, 7, 8]
  r = a.pop
  raise unless r == 8
  raise unless a == [1, 2, 3, 4, 5, 6, 7]
end

def dynamic_pop
  a = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  r = a.pop
  raise unless r == 9
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8]

  a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
  r = a.pop
  raise unless r == 17
  raise unless a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
end

def reverse
  a = []
  a.reverse!
  raise unless a == []

  a = [1]
  a.reverse!
  raise unless a == [1]

  a = [1, 2]
  a.reverse!
  raise unless a == [2, 1]

  a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  a.reverse!
  raise unless a == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
end

########################################
# Array#max
########################################

def max
  # Empty array returns nil.
  raise "Expected [].max to be nil, got #{[].max.inspect}" unless [].max.nil?

  # Single-element array returns the element.
  raise "Expected [1].max to be 1, got #{[1].max.inspect}" unless [1].max == 1
  raise "Expected [-5].max to be -5, got #{[-5].max.inspect}" unless [-5].max == -5

  # Integer arrays.
  raise "Expected [1,2].max == 2, got #{[1, 2].max.inspect}" unless [1, 2].max == 2
  raise "Expected [2,1].max == 2, got #{[2, 1].max.inspect}" unless [2, 1].max == 2
  raise "Expected [18,42].max == 42" unless [18, 42].max == 42
  raise "Expected [2,5,3,6,1,4].max == 6" unless [2, 5, 3, 6, 1, 4].max == 6

  # String arrays.
  raise "Expected strings max == 'tt'" unless %w[aa tt].max == 'tt'
  raise "Expected strings max == '4'" unless %w[2 33 4 11].max == '4'

  # With block as comparator.
  result = %w[2 33 4 11].max { |a, b| a <=> b }
  raise "Expected block max == '4', got #{result.inspect}" unless result == '4'

  result = [2, 33, 4, 11].max { |a, b| a <=> b }
  raise "Expected block max == 33, got #{result.inspect}" unless result == 33

  # Reversed comparator finds the minimum.
  result = %w[2 33 4 11].max { |a, b| b <=> a }
  raise "Expected reversed block max == '11', got #{result.inspect}" unless result == '11'

  # Block receives (el, current_max) pairwise.
  yielded = []
  [1, 2, 3, 4, 5].max { |el, _cur| yielded << el; el }
  raise "Expected yielded [2,3,4,5], got #{yielded.inspect}" unless yielded == [2, 3, 4, 5]

  # Homogeneous nested arrays (Array#<=> is lexicographic).
  raise "Expected [[6,7,8,9]]" unless [[1, 2], [3, 4, 5], [6, 7, 8, 9]].max == [6, 7, 8, 9]

  # max(n): top N in descending order.
  raise "Expected [], got #{[].max(5).inspect}" unless [].max(5) == []
  raise "Expected [], got #{[1, 2, 3].max(0).inspect}" unless [1, 2, 3].max(0) == []
  raise "Expected [3], got #{[1, 2, 3].max(1).inspect}" unless [1, 2, 3].max(1) == [3]
  raise "Expected [3,2], got #{[1, 2, 3].max(2).inspect}" unless [1, 2, 3].max(2) == [3, 2]
  raise "Expected [3,2,1], got #{[1, 2, 3].max(3).inspect}" unless [1, 2, 3].max(3) == [3, 2, 1]
  # Over-count clamps to length.
  raise "Expected [3,2,1], got #{[1, 2, 3].max(10).inspect}" unless [1, 2, 3].max(10) == [3, 2, 1]

  # With a block comparator.
  result = [5, 1, 4, 2, 3].max(3) { |a, b| a <=> b }
  raise "Expected [5,4,3], got #{result.inspect}" unless result == [5, 4, 3]

  # Negative n raises ArgumentError.
  raised = false
  begin
    [1, 2].max(-1)
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for max(-1)' unless raised
end

########################################
# Array#min
########################################

def min
  # Empty array returns nil.
  raise "Expected [].min to be nil, got #{[].min.inspect}" unless [].min.nil?

  # Single-element array returns the element.
  raise "Expected [1].min to be 1, got #{[1].min.inspect}" unless [1].min == 1

  # Integer arrays.
  raise "Expected [1,2].min == 1, got #{[1, 2].min.inspect}" unless [1, 2].min == 1
  raise "Expected [2,1].min == 1, got #{[2, 1].min.inspect}" unless [2, 1].min == 1
  raise "Expected [2,5,3,6,1,4].min == 1" unless [2, 5, 3, 6, 1, 4].min == 1

  # String arrays.
  raise "Expected strings min == 'aa'" unless %w[aa tt].min == 'aa'

  # With block as comparator.
  result = [2, 33, 4, 11].min { |a, b| a <=> b }
  raise "Expected block min == 2, got #{result.inspect}" unless result == 2

  # Reversed comparator finds the maximum.
  result = [2, 33, 4, 11].min { |a, b| b <=> a }
  raise "Expected reversed block min == 33, got #{result.inspect}" unless result == 33

  # Block yields the last length-1 values.
  yielded = []
  [1, 2, 3, 4, 5].min { |el, _cur| yielded << el; -el }
  raise "Expected yielded [2,3,4,5], got #{yielded.inspect}" unless yielded == [2, 3, 4, 5]

  # min(n): bottom N in ascending order.
  raise "Expected [], got #{[].min(5).inspect}" unless [].min(5) == []
  raise "Expected [], got #{[1, 2, 3].min(0).inspect}" unless [1, 2, 3].min(0) == []
  raise "Expected [1], got #{[1, 2, 3].min(1).inspect}" unless [1, 2, 3].min(1) == [1]
  raise "Expected [1,2], got #{[3, 1, 2].min(2).inspect}" unless [3, 1, 2].min(2) == [1, 2]
  raise "Expected [1,2,3], got #{[3, 1, 2].min(3).inspect}" unless [3, 1, 2].min(3) == [1, 2, 3]
  # Over-count clamps to length.
  raise "Expected [1,2,3], got #{[3, 1, 2].min(10).inspect}" unless [3, 1, 2].min(10) == [1, 2, 3]

  # With a block comparator.
  result = [5, 1, 4, 2, 3].min(2) { |a, b| a <=> b }
  raise "Expected [1,2], got #{result.inspect}" unless result == [1, 2]

  # Negative n raises ArgumentError.
  raised = false
  begin
    [1, 2].min(-1)
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for min(-1)' unless raised
end

########################################
# Array#zip
########################################

def zip
  # Equal length arrays.
  result = [1, 2, 3, 4].zip(%w[a b c d e])
  expected = [[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd']]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Shorter argument — missing values become nil.
  result = [1, 2, 3, 4, 5].zip(%w[a b c d])
  expected = [[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd'], [5, nil]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Multiple arguments.
  result = [1, 2, 3].zip([4, 5, 6], [7, 8, 9])
  expected = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Zero arguments — one-tuples.
  result = [1, 2, 3].zip
  expected = [[1], [2], [3]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Empty self.
  result = [].zip([1, 2, 3])
  raise "Expected [], got #{result.inspect}" unless result == []

  # Block form returns nil and yields each tuple.
  values = []
  block_result = [1, 2, 3, 4].zip(%w[a b c d e]) { |v| values << v }
  raise "Expected block zip to return nil, got #{block_result.inspect}" unless block_result.nil?
  expected_values = [[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd']]
  raise "Expected block yielded #{expected_values.inspect}, got #{values.inspect}" unless values == expected_values
end

########################################
# Array#product
########################################

def product
  # Empty receiver — no tuples.
  raise "Expected [], got #{[].product([1, 2]).inspect}" unless [].product([1, 2]) == []

  # Single factor with no arguments — one-tuples of self.
  raise "Expected [[1],[2]], got #{[1, 2].product.inspect}" unless [1, 2].product == [[1], [2]]

  # Simple two-factor product.
  result = [1, 2].product([3, 4])
  expected = [[1, 3], [1, 4], [2, 3], [2, 4]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Three-factor product (reference from ruby/spec).
  result = [1, 2].product([3, 4, 5], [6, 8])
  expected = [[1, 3, 6], [1, 3, 8], [1, 4, 6], [1, 4, 8], [1, 5, 6], [1, 5, 8],
              [2, 3, 6], [2, 3, 8], [2, 4, 6], [2, 4, 8], [2, 5, 6], [2, 5, 8]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Empty argument array → empty product.
  raise "Expected [], got #{[1, 2].product([]).inspect}" unless [1, 2].product([]) == []

  # Non-Array, non-to_ary argument raises TypeError.
  raised = false
  begin
    [1].product(2..3) # rubocop:disable Lint/LiteralInInterpolation
  rescue TypeError
    raised = true
  end
  raise 'Expected TypeError for Range argument' unless raised

  # Block form yields each tuple and returns self.
  yielded = []
  result = [1, 2].product([3, 4]) { |t| yielded << t }
  raise "Expected block result to be self, got #{result.inspect}" unless result.equal?([1, 2]) || result == [1, 2]
  expected_yielded = [[1, 3], [1, 4], [2, 3], [2, 4]]
  raise "Expected yielded #{expected_yielded.inspect}, got #{yielded.inspect}" unless yielded == expected_yielded
end

########################################
# Array#sample
########################################

def sample
  # Empty array, zero-arg form → nil.
  raise "Expected nil, got #{[].sample.inspect}" unless [].sample.nil?

  # Single element, zero-arg form → that element.
  raise "Expected 4, got #{[4].sample.inspect}" unless [4].sample == 4

  # Zero-arg form on a multi-element array returns something from the
  # array. We can't assert which one (it's random), but we can assert
  # membership.
  array = [1, 2, 3, 4]
  10.times do
    pick = array.sample
    raise "sample #{pick.inspect} not in #{array.inspect}" unless array.include?(pick)
  end

  # Zero-count form returns [].
  raise "Expected [], got #{[4].sample(0).inspect}" unless [4].sample(0) == []

  # Integer count form returns an Array instance.
  result = [1, 2, 3, 4].sample(3)
  raise "Expected Array, got #{result.class}" unless result.is_a?(Array)
  raise "Expected size 3, got #{result.size}" unless result.size == 3
  # All returned elements are from the source.
  result.each do |el|
    raise "sampled #{el.inspect} not in source" unless array.include?(el)
  end

  # Count larger than the array clamps to array length.
  result = [1, 2, 3, 4].sample(20)
  raise "Expected size 4, got #{result.size}" unless result.size == 4
  # And with distinct source values, the result contains each exactly once.
  raise "Expected sorted result to equal source, got #{result.sort.inspect}" unless result.sort == array

  # Duplicate source may return duplicates.
  result = [4, 4].sample(2)
  raise "Expected [4,4], got #{result.inspect}" unless result == [4, 4]

  # Negative count raises ArgumentError.
  raised = false
  begin
    [1, 2].sample(-1)
  rescue ArgumentError
    raised = true
  end
  raise 'Expected ArgumentError for negative count' unless raised

  # Options hash is accepted (even if not yet routed to a custom RNG).
  result = [1, 2, 3, 4].sample(2, {})
  raise "Expected size 2 with options hash, got #{result.size}" unless result.size == 2
end

########################################
# Array#repeated_combination
########################################

def repeated_combination
  a = [10, 11, 12]

  # Two-element combinations (with replacement).
  result = a.repeated_combination(2).sort
  expected = [[10, 10], [10, 11], [10, 12], [11, 11], [11, 12], [12, 12]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Three-element combinations.
  result = a.repeated_combination(3).sort
  expected = [[10, 10, 10], [10, 10, 11], [10, 10, 12], [10, 11, 11], [10, 11, 12],
              [10, 12, 12], [11, 11, 11], [11, 11, 12], [11, 12, 12], [12, 12, 12]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Length 0 yields one empty combination.
  raise 'Expected [[]]' unless a.repeated_combination(0) == [[]]
  raise 'Expected [[]]' unless [].repeated_combination(0) == [[]]

  # Negative length yields nothing and returns self when given a block.
  counter = 0
  result = a.repeated_combination(-1) { |_| counter += 1 }
  raise 'Expected return == self for negative length' unless result.equal?(a)
  raise "Expected 0 yields for negative length, got #{counter}" unless counter == 0

  # Block form: returns self.
  counter = 0
  result = a.repeated_combination(2) { |_| counter += 1 }
  raise 'Expected block form to return self' unless result.equal?(a)
  raise "Expected 6 yields, got #{counter}" unless counter == 6

  # Empty receiver + nonzero length → nothing.
  raise 'Expected []' unless [].repeated_combination(3) == []
end

########################################
# Array#repeated_permutation
########################################

def repeated_permutation
  a = [10, 11, 12]

  # Two-element permutations (with replacement).
  result = a.repeated_permutation(2).sort
  expected = [[10, 10], [10, 11], [10, 12], [11, 10], [11, 11], [11, 12],
              [12, 10], [12, 11], [12, 12]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Length 0 yields one empty permutation.
  raise 'Expected [[]]' unless a.repeated_permutation(0) == [[]]
  raise 'Expected [[]]' unless [].repeated_permutation(0) == [[]]

  # Empty receiver + nonzero length yields nothing.
  raise 'Expected []' unless [].repeated_permutation(10) == []

  # Handles duplicates correctly.
  dup_src = [10, 11, 10]
  result = dup_src.repeated_permutation(2).sort
  expected = [[10, 10], [10, 10], [10, 10], [10, 10], [10, 11],
              [10, 11], [11, 10], [11, 10], [11, 11]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

  # Block form: returns self.
  counter = 0
  result = a.repeated_permutation(2) { |_| counter += 1 }
  raise 'Expected block form to return self' unless result.equal?(a)
  raise "Expected 9 yields, got #{counter}" unless counter == 9
end

spec if $PROGRAM_NAME == __FILE__
