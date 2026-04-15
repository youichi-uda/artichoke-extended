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

spec if $PROGRAM_NAME == __FILE__
