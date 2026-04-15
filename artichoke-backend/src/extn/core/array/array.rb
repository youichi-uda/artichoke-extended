# frozen_string_literal: true

module Artichoke
  class Array
    # rubocop:disable Lint/HashCompareByIdentity
    def self.inspect(ary, recur_list)
      size = ary.size
      return '[]' if size.zero?
      return '[...]' if recur_list[ary.object_id]

      recur_list[ary.object_id] = true
      out = []
      i = 0
      while i < size
        elem = ary[i]
        out <<
          case elem
          when ::Array
            ::Artichoke::Array.inspect(elem, recur_list)
          when ::Hash
            ::Artichoke::Hash.inspect(elem, recur_list)
          else
            elem.inspect
          end

        i += 1
      end
      "[#{out.join(', ')}]"
    end
    # rubocop:enable Lint/HashCompareByIdentity
  end
end

class Array
  # include depends on Array#reverse which hasn't been defined yet so inline the
  # `Module` include.
  #
  # include Enumerable
  Enumerable.append_features(self)
  Enumerable.included(self)

  def self.try_convert(other)
    ary = other.to_ary
    return nil if ary.nil?
    unless ary.is_a?(Array)
      raise TypeError, "can't convert #{other.class} to Array (#{other.class}#to_ary gives #{ary.class})"
    end

    ary
  rescue NoMethodError
    nil
  end

  def &(other)
    raise TypeError, "can't convert #{other.class} into Array" unless other.is_a?(Array)

    hash = {}
    array = []
    idx = 0
    len = other.size
    while idx < len
      hash[other[idx]] = true
      idx += 1
    end
    idx = 0
    len = size
    while idx < len
      v = self[idx]
      if hash[v]
        array << v
        hash.delete v
      end
      idx += 1
    end
    array
  end

  def -(other)
    ary = other.to_ary if other.respond_to?(:to_ary)
    classname = other.class
    classname = other.inspect if other.nil? || other.equal?(false) || other.equal?(true)
    raise TypeError, "no implicit conversion of #{classname} into #{self.class}" unless ary.is_a?(Array)

    hash = {}
    array = []
    idx = 0
    len = ary.size
    while idx < len
      hash[ary[idx]] = true
      idx += 1
    end
    idx = 0
    len = size
    while idx < len
      v = self[idx]
      array << v unless hash[v]
      idx += 1
    end
    array
  end

  def <=>(other)
    return nil unless other.is_a?(Array)

    len = length
    return len <=> other.length unless len == other.length

    idx = 0
    while idx < len
      if self[idx].equal?(other[idx])
        idx += 1
        next
      end
      cmp = self[idx] <=> other[idx]
      return false if cmp.nil?

      unless cmp.is_a?(Numeric)
        classname = other.class
        classname = other.inspect if other.nil? || other.equal?(false) || other.equal?(true) || other.is_a?(Numeric)
        raise ArgumentError, "Comparison of #{self.class} with #{classname} failed"
      end

      return cmp unless cmp.zero?

      idx += 1
    end
    0
  end

  def ==(other)
    return false unless other.is_a?(Array)
    return false unless length == other.length

    len = length
    idx = 0
    while idx < len
      left = self[idx]
      right = other[idx]
      idx += 1
      next if left.equal?(right)

      if left.is_a?(Comparable)
        cmp = left <=> right
        return false if cmp.nil?
        raise ArgumentError unless cmp.is_a?(Numeric)
        return false unless cmp.zero?
      else
        return false unless left == right
      end
    end
    true
  rescue NoMethodError
    false
  end

  def all?(pattern = (not_set = true), &block)
    if not_set
      idx = 0
      if block
        while idx < length
          return false unless block.call(self[idx])

          idx += 1
        end
      else
        len = length
        while idx < len
          return false unless self[idx]

          idx += 1
        end
      end
    else
      warn('warning: given block not used') if block

      len = length
      idx = 0
      while idx < len
        return false unless pattern === self[idx] # rubocop:disable Style/CaseEquality

        idx += 1
      end
    end
    true
  end

  def any?(pattern = (not_set = true), &block)
    if not_set
      idx = 0
      if block
        while idx < length
          return true if block.call(self[idx])

          idx += 1
        end
      else
        len = length
        while idx < len
          return true if self[idx]

          idx += 1
        end
      end
    else
      warn('warning: given block not used') if block

      len = length
      idx = 0
      while idx < len
        return true if pattern === self[idx] # rubocop:disable Style/CaseEquality

        idx += 1
      end
    end
    false
  end

  def assoc(obj)
    idx = 0
    len = length
    while idx < len
      ary = self[idx]
      idx += 1
      next unless ary.is_a?(Array)
      next unless ary.length.positive?

      return ary if ary.first == obj
    end
    nil
  end

  def at(index)
    raise TypeError, 'no implicit conversion from nil to integer' if index.nil?

    idx =
      if index.is_a?(Integer)
        index
      elsif index.respond_to?(:to_int)
        classname = index.class
        classname = index.inspect if index.equal?(false) || index.equal?(true)
        idx = index.to_int
        unless idx.is_a?(Integer)
          raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{idx.class})"
        end

        idx
      else
        classname = index.class
        classname = index.inspect if index.equal?(false) || index.equal?(true)
        raise TypeError, "no implicit conversion of #{classname} into Integer"
      end

    self[idx]
  end

  def bsearch(&block)
    return to_enum :bsearch unless block

    idx = bsearch_index(&block)
    return self[idx] unless index.nil?

    nil
  end

  def bsearch_index(&block)
    return to_enum :bsearch_index unless block

    low = 0
    high = size
    satisfied = false

    while low < high
      mid = ((low + high) / 2).truncate
      res = block.call self[mid]

      case res
      when 0 # find-any mode: Found!
        return mid
      when Numeric # find-any mode: Continue...
        in_lower_half = res.negative?
      when true # find-min mode
        in_lower_half = true
        satisfied = true
      when false, nil # find-min mode
        in_lower_half = false
      else
        raise TypeError, 'invalid block result (must be numeric, true, false or nil)'
      end

      if in_lower_half
        high = mid
      else
        low = mid + 1
      end
    end

    satisfied ? low : nil
  end

  def collect(&block)
    return to_enum :collect unless block

    ary = []
    idx = 0
    while idx < length
      ary << block.call(self[idx])
      idx += 1
    end
    ary
  end

  def collect!(&block)
    return to_enum :collect! unless block
    raise FrozenError, "can't modify frozen Array" if frozen?

    idx = 0
    while idx < length
      self[idx] = block.call(self[idx])
      idx += 1
    end
    self
  end

  def combination(k, &block) # rubocop:disable Naming/MethodParameterName
    k =
      if k.is_a?(Integer)
        k
      elsif k.nil?
        raise TypeError, 'no implicit conversion from nil to integer'
      elsif k.respond_to?(:to_int)
        classname = k.class
        classname = k.inspect if k.equal?(false) || k.equal?(true)
        k = k.to_int
        unless k.is_a?(Integer)
          raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{k.class})"
        end

        k
      else
        classname = k.class
        classname = k.inspect if k.equal?(false) || k.equal?(true)
        raise TypeError, "no implicit conversion of #{classname} into Integer"
      end

    return to_enum(:combination, k) unless block
    return self if k > length
    return self if k.negative?

    if k.zero?
      block.call([])
    elsif k == 1
      ary = dup
      len = length
      idx = 0
      while idx < len
        block.call([ary[idx]])
        idx += 1
      end
    elsif k == length
      block.call(dup)
    else
      ary = dup
      len = length
      indexes = (0...k).to_a
      incr = k - 1
      loop do
        while indexes[incr] < len
          block.call(indexes.map { |i| ary[i] })
          indexes[incr] += 1
        end

        reset = incr
        until reset.negative?
          reset -= 1
          prev = indexes[reset]
          break unless prev + 1 >= len
        end
        base = indexes[reset] + 1
        replace = k - reset
        indexes[reset, replace] = (base...(base + replace)).to_a
        break if indexes[0] + k > len

        incr = k - 1
      end
    end
    self
  end

  def compact
    reject(&:nil?)
  end

  def compact!
    raise FrozenError, "can't modify frozen Array" if frozen?

    reject!(&:nil?)
  end

  def count(obj = (not_set = true), &block)
    count = 0
    idx = 0
    len = length
    if not_set
      return len unless block

      while idx < len
        item = self[idx]
        count += 1 if block.call(item)
        idx += 1
      end
    else
      warn('warning: given block not used') if block

      while idx < len
        item = self[idx]
        count += 1 if obj == item
        idx += 1
      end
    end
    count
  end

  def cycle(num = nil, &block)
    return to_enum(:cycle, num) unless block

    if num.nil?
      return nil if empty?

      while true
        idx = 0
        len = length
        while idx < len
          block.call(self[idx])
          idx += 1
        end
      end
    else
      count =
        if num.is_a?(Integer)
          num
        elsif num.respond_to?(:to_int)
          classname = num.class
          classname = num.inspect if num.equal?(false) || num.equal?(true)
          num = num.to_int
          unless num.is_a?(Integer)
            raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{num.class})"
          end

          num
        else
          classname = num.class
          classname = num.inspect if num.equal?(false) || num.equal?(true)
          raise TypeError, "no implicit conversion of #{classname} into Integer"
        end
      return nil unless count.positive?

      iteration = 0
      while iteration < count
        idx = 0
        len = length
        while idx < len
          block.call(self[idx])
          idx += 1
        end
        iteration += 1
      end
    end
  end

  def delete(key, &block)
    sentinel = Object.new
    ret = sentinel
    while (i = index(key))
      ret = delete_at(i)
    end

    return block.call if ret.equal?(sentinel) && block
    return nil if ret.equal?(sentinel)

    ret
  end

  def delete_at(index)
    raise FrozenError, "can't modify frozen Array" if frozen?

    index =
      if index.is_a?(Integer)
        index
      elsif index.nil?
        raise TypeError, 'no implicit conversion from nil to integer'
      elsif index.respond_to?(:to_int)
        classname = index.class
        classname = index.inspect if index.equal?(false) || index.equal?(true)
        index = index.to_int
        unless index.is_a?(Integer)
          raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{index.class})"
        end

        index
      else
        classname = index.class
        classname = index.inspect if index.equal?(false) || index.equal?(true)
        raise TypeError, "no implicit conversion of #{classname} into Integer"
      end
    index += length if index.negative?
    return nil if index >= length
    return nil if index.negative?

    ret = self[index]
    self[index, 1] = []
    ret
  end

  def delete_if(&block)
    return to_enum :delete_if unless block
    raise FrozenError, "can't modify frozen Array" if frozen?

    idx = 0
    delete_indexes = []
    while idx < size
      delete_indexes << idx if block.call(self[idx])

      idx += 1
    end
    delete_indexes.reverse_each { |index| delete_at(index) }
    self
  end

  def dig(idx, *args)
    item = self[idx]
    if args.empty?
      item
    else
      item&.dig(*args)
    end
  end

  def drop(num)
    count =
      if num.is_a?(Integer)
        num
      elsif num.nil?
        raise TypeError, 'no implicit conversion from nil to integer'
      elsif num.respond_to?(:to_int)
        classname = num.class
        classname = num.inspect if index.equal?(false) || index.equal?(true)
        num = num.to_int
        unless num.is_a?(Integer)
          raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{num.class})"
        end

        num
      else
        classname = num.class
        classname = num.inspect if index.equal?(false) || index.equal?(true)
        raise TypeError, "no implicit conversion of #{classname} into Integer"
      end
    raise ArgumentError, 'attempt to drop negative size' if count.negative?
    return self if count.zero?

    self[0, count] = []
    self
  end

  def drop_while(&block)
    return to_enum(:drop_while) unless block

    drop_until = 0
    idx = 0
    while idx < length
      drop = block.call(self[idx])
      drop_until += 1 if drop
      break unless drop

      idx += 1
    end
    self[0, drop_until] = []
    self
  end

  def each(&block)
    return to_enum :each unless block

    idx = 0
    while idx < length
      block.call(self[idx])
      idx += 1
    end
    self
  end

  def each_index(&block)
    return to_enum :each_index unless block

    idx = 0
    while idx < length
      block.call(idx)
      idx += 1
    end
    self
  end

  def empty?
    length.zero?
  end

  def eql?(other)
    return true if equal?(other)
    return false unless other.is_a?(Array)
    return false if length != other.length

    len = length
    i = 0
    while i < len
      s = self[i]
      o = other[i]
      i += 1
      return false unless s.eql?(o)
    end
    true
  end

  def fetch(index, default = (not_set = true), &block)
    warn 'block supersedes default value argument' if !index.nil? && !not_set && block

    idx = index
    idx += size if idx.negative?
    if idx.negative? || size <= idx
      return block.call(index) if block
      raise IndexError, "index #{idx} outside of array bounds: #{-size}...#{size}" if not_set

      return default
    end
    self[idx]
  end

  def fill(arg0 = nil, arg1 = nil, arg2 = nil, &block)
    raise ArgumentError, 'wrong number of arguments (0 for 1..3)' if arg0.nil? && arg1.nil? && arg2.nil? && !block

    beg = len = 0
    if block
      if arg0.nil? && arg1.nil? && arg2.nil?
        # ary.fill { |index| block }                    -> ary
        beg = 0
        len = size
      elsif !arg0.nil? && arg0.is_a?(Range)
        # ary.fill(range) { |index| block }             -> ary
        beg = arg0.begin
        beg += size if beg.negative?
        len = arg0.end
        len += size if len.negative?
        len += 1 unless arg0.exclude_end?
      elsif !arg0.nil?
        # ary.fill(start [, length] ) { |index| block } -> ary
        beg = arg0
        beg += size if beg.negative?
        len =
          if arg1.nil?
            size
          else
            arg0 + arg1
          end
      end
    elsif !arg0.nil? && arg1.nil? && arg2.nil?
      # ary.fill(obj)                                 -> ary
      beg = 0
      len = size
    elsif !arg0.nil? && !arg1.nil? && arg1.is_a?(Range)
      # ary.fill(obj, range )                         -> ary
      beg = arg1.begin
      beg += size if beg.negative?
      len = arg1.end
      len += size if len.negative?
      len += 1 unless arg1.exclude_end?
    elsif !arg0.nil? && !arg1.nil?
      # ary.fill(obj, start [, length])               -> ary
      beg = arg1
      beg += size if beg.negative?
      len =
        if arg2.nil?
          size
        else
          beg + arg2
        end
    end

    raise ArgumentError, 'argument too big' if len > (2**(0.size * 8)) - 1

    i = beg
    if block
      while i < len
        self[i] = block.call(i)
        i += 1
      end
    else
      while i < len
        self[i] = arg0
        i += 1
      end
    end
    self
  end

  def filter(&block)
    return to_enum(:filter) unless block

    res = []
    idx = 0
    len = length
    while idx < len
      item = self[idx]
      res << item if block.call(item).equal?(true)
      idx += 1
    end
    res
  end

  def filter!(&block)
    return to_enum(:filter!) unless block

    res = filter(&block)
    return nil if length == res.length

    self[0, length] = res
  end

  def find_index(obj = (not_set = true), &block)
    return to_enum(:find_index, obj) if !block && not_set

    idx = 0
    len = length
    if not_set
      while idx < len
        item = self[idx]
        return idx if block.call(item).equal?(true)

        idx += 1
      end
    else
      warn('warning: given block not used') if block

      while idx < len
        item = self[idx]
        return idx if obj == item

        idx += 1
      end
    end
    nil
  end

  def flatten(depth = nil)
    res = dup
    res.flatten! depth
    res
  end

  def flatten!(depth = nil)
    modified = false
    ar = []
    idx = 0
    len = length
    while idx < len
      e = self[idx]
      if e.is_a?(Array) && (depth.nil? || depth.positive?)
        ar.concat(e.flatten(depth.nil? ? nil : depth - 1))
        modified = true
      else
        ar << e
      end
      idx += 1
    end
    self[0, len] = ar if modified
  end

  def include?(object)
    idx = 0
    len = length
    while idx < len
      return true if self[idx] == object

      idx += 1
    end
    false
  end

  def index(val = (not_set = true), &block)
    return to_enum(:index) if !block && not_set # rubocop:disable Lint/ToEnumArguments

    idx = 0
    if not_set
      while idx < length
        return idx if block.call(self[idx])

        idx += 1
      end
    else
      warn('warning: given block not used') if block

      len = length
      while idx < len
        return idx if self[idx] == val

        idx += 1
      end
    end
    nil
  end

  def insert(idx, *args)
    idx += size + 1 if idx.negative?

    self[idx, 0] = args
    self
  end

  def inspect
    ::Artichoke::Array.inspect(self, {})
  end

  def join(separator = $,) # rubocop:disable Style/SpecialGlobalVars
    classname = separator.class
    classname = separator.inspect if separator.equal?(true) || separator.equal?(false)

    separator = '' if separator.nil?
    sep = String.try_convert(separator)
    raise "No implicit conversion of #{classname} into String" if sep.nil?

    s = +''
    idx = 0
    len = size
    while idx < len
      s << self[idx].to_s
      s << sep if idx < len - 1
      idx += 1
    end
    s
  end

  def keep_if(&block)
    return to_enum :keep_if unless block

    idx = 0
    while idx < size
      if block.call(self[idx])
        idx += 1
      else
        delete_at(idx)
      end
    end
    self
  end

  # Returns the maximum element. With a block, the block is used as a
  # comparator between each subsequent element and the running maximum.
  #
  # With an integer `n`, returns the top `n` elements of the array
  # sorted in descending order, clamped to the receiver's length.
  #
  # For empty arrays, `max` returns `nil` and `max(n)` returns `[]`.
  # For single-element arrays, `max` returns the element. Behaviour
  # matches ruby/spec `core/array/max_spec.rb`.
  def max(n = nil, &block)
    if n.nil?
      len = length
      return nil if len.zero?

      result = self[0]
      idx = 1
      if block
        while idx < len
          el = self[idx]
          cmp = block.call(el, result)
          raise ArgumentError, 'comparison of elements failed' if cmp.nil?
          raise ArgumentError, 'comparison of elements failed' unless cmp.is_a?(Integer)

          result = el if cmp > 0
          idx += 1
        end
      else
        while idx < len
          el = self[idx]
          cmp = el <=> result
          raise ArgumentError, "comparison of #{el.class} with #{result.class} failed" if cmp.nil?

          result = el if cmp > 0
          idx += 1
        end
      end
      return result
    end

    __top_n(n, :max, &block)
  end

  # Returns the minimum element. With a block, the block is used as a
  # comparator between each subsequent element and the running minimum.
  #
  # With an integer `n`, returns the bottom `n` elements of the array
  # sorted in ascending order, clamped to the receiver's length.
  #
  # For empty arrays, `min` returns `nil` and `min(n)` returns `[]`.
  # For single-element arrays, `min` returns the element. Behaviour
  # matches ruby/spec `core/array/min_spec.rb`.
  def min(n = nil, &block)
    if n.nil?
      len = length
      return nil if len.zero?

      result = self[0]
      idx = 1
      if block
        while idx < len
          el = self[idx]
          cmp = block.call(el, result)
          raise ArgumentError, 'comparison of elements failed' if cmp.nil?
          raise ArgumentError, 'comparison of elements failed' unless cmp.is_a?(Integer)

          result = el if cmp < 0
          idx += 1
        end
      else
        while idx < len
          el = self[idx]
          cmp = el <=> result
          raise ArgumentError, "comparison of #{el.class} with #{result.class} failed" if cmp.nil?

          result = el if cmp < 0
          idx += 1
        end
      end
      return result
    end

    __top_n(n, :min, &block)
  end

  # Internal helper shared by `Array#max(n)` and `Array#min(n)`.
  #
  # Coerces `n` through `#to_int`, rejects negative counts with
  # `ArgumentError` ("negative size ..."), clamps to `length`, and
  # returns the top / bottom `n` elements — sorted descending for
  # `:max`, ascending for `:min` — matching CRuby's behaviour.
  def __top_n(n, direction, &block)
    count =
      if n.is_a?(Integer)
        n
      elsif n.respond_to?(:to_int)
        converted = n.to_int
        unless converted.is_a?(Integer)
          raise TypeError,
                "can't convert #{n.class} to Integer (#{n.class}#to_int gives #{converted.class})"
        end
        converted
      else
        raise TypeError, "no implicit conversion of #{n.class} into Integer"
      end

    raise ArgumentError, 'negative size (-1)' if count.negative?
    return [] if count.zero? || empty?

    sorted =
      if block
        sort(&block)
      else
        sort
      end

    if direction == :max
      # Top `count` elements in descending order. `sort` put the
      # smallest first, so slice the tail and reverse.
      tail = sorted.length - count
      tail = 0 if tail.negative?
      sorted[tail..-1].reverse
    else
      # Bottom `count` elements in ascending order — the sorted
      # prefix, which `sort` already produced for us.
      sorted[0, count]
    end
  end

  def none?(pattern = (not_set = true), &block)
    if not_set
      idx = 0
      if block
        while idx < length
          return false if block.call(self[idx]).equal?(true)

          idx += 1
        end
      else
        len = length
        while idx < len
          return false if self[idx].equal?(true)

          idx += 1
        end
      end
    else
      warn('warning: given block not used') if block

      len = length
      idx = 0
      while idx < len
        return false if pattern === self[idx] # rubocop:disable Style/CaseEquality

        idx += 1
      end
    end
    true
  end

  def permutation(kcombinations = size, &block)
    size = self.size
    return to_enum(:permutation, kcombinations) unless block
    return if kcombinations > size

    if kcombinations.zero?
      yield []
    else
      i = 0
      while i < size
        result = [self[i]]
        if (kcombinations - 1).positive?
          ary = self[0...i] + self[(i + 1)..-1]
          ary.permutation(kcombinations - 1) do |c|
            yield result + c
          end
        else
          yield result
        end
        i += 1
      end
    end
  end

  # Returns the Cartesian product of `self` and each of the argument arrays.
  # If a block is given, yields each tuple in turn and returns `self`.
  #
  # Matches ruby/spec `core/array/product_spec.rb`:
  #   [1,2].product([3,4,5], [6,8])
  #   # => [[1,3,6], [1,3,8], [1,4,6], [1,4,8], [1,5,6], [1,5,8],
  #   #     [2,3,6], [2,3,8], [2,4,6], [2,4,8], [2,5,6], [2,5,8]]
  #
  # Each argument must already be an Array or support `#to_ary`.
  # `nil`, `Range`, and other iterables are rejected with `TypeError`,
  # matching CRuby: `[1].product(2..3)` raises.
  def product(*others, &block)
    # Coerce arguments to Arrays via `#to_ary`. Unlike `zip`, `product` does
    # NOT fall back to `#each` — the spec requires a `TypeError` for things
    # like Ranges, so we reject anything that isn't already an Array and
    # doesn't respond to `#to_ary`.
    arrays = others.map do |other|
      if other.is_a?(Array)
        other
      elsif other.respond_to?(:to_ary)
        converted = other.to_ary
        unless converted.is_a?(Array)
          classname = other.class
          raise TypeError,
                "can't convert #{classname} to Array (#{classname}#to_ary gives #{converted.class})"
        end
        converted
      else
        raise TypeError, "no implicit conversion of #{other.class} into Array"
      end
    end

    # Guard against accidental DoS. CRuby raises RangeError when the total
    # number of tuples would exceed what a C `long` can hold; we use
    # 2**62 - 1 as a conservative cap that keeps the Ruby-level behaviour
    # consistent with ruby/spec's `a.product(a,a,a,...)` over-use assertion.
    factor_count = length
    arrays.each do |arr|
      len = arr.length
      # Short-circuit: any empty factor means the product is empty.
      if len.zero?
        return self if block

        return []
      end
      factor_count *= len
      raise RangeError, 'too big to product' if factor_count > ((1 << 62) - 1)
    end

    if length.zero?
      return self if block

      return []
    end

    factors = [self] + arrays
    total_factors = factors.length
    indices = Array.new(total_factors, 0)
    results = block ? nil : []

    loop do
      # Materialise the current tuple.
      tuple = Array.new(total_factors)
      i = 0
      while i < total_factors
        tuple[i] = factors[i][indices[i]]
        i += 1
      end

      if block
        block.call(tuple)
      else
        results << tuple
      end

      # Increment like an odometer, from the rightmost position.
      pos = total_factors - 1
      while pos >= 0
        indices[pos] += 1
        break if indices[pos] < factors[pos].length

        indices[pos] = 0
        pos -= 1
      end
      break if pos < 0
    end

    block ? self : results
  end

  def rassoc(obj)
    idx = 0
    len = length
    while idx < len
      ary = self[idx]
      idx += 1
      next unless ary.is_a?(Array)
      next unless ary.length.positive?

      return ary if ary[1] == obj
    end
    nil
  end

  def reject(&block)
    return to_enum :reject unless block

    ary = []
    idx = 0
    while idx < length
      item = self[idx]
      ary << item unless block.call(item)
      idx += 1
    end
    ary
  end

  def reject!(&block)
    return to_enum :reject! unless block

    ary = []
    idx = 0
    modified = false
    while idx < length
      item = self[idx]
      if block.call(item)
        modified = true
      else
        ary << item
      end
      idx += 1
    end
    return nil unless modified

    self[0, length] = ary
    self
  end

  def repeated_combination(_num)
    raise NotImplementedError
  end

  def repeated_permutation(_num)
    raise NotImplementedError
  end

  def replace(other)
    classname = other.class
    classname = other.inspect if other.equal?(true) || other.equal?(false) || other.nil?
    ary =
      if other.is_a?(Array)
        other
      elsif other.respond_to?(:to_ary)
        other = other.to_ary
        unless other.is_a?(Array)
          raise TypeError, "can't convert #{classname} to Array (#{classname}#to_ary gives #{other.class})"
        end

        other
      else
        raise TypeError, "no implicit conversion of #{classname} into Array" unless other.is_a?(Array)
      end
    self[0, length] = ary
    self
  end

  def reverse_each(&block)
    return to_enum :reverse_each unless block

    i = size - 1
    while i >= 0
      block.call(self[i])
      i -= 1
    end
    self
  end

  def rindex(val = (not_set = true), &block)
    return to_enum(:rindex) if !block && not_set # rubocop:disable Lint/ToEnumArguments

    if not_set
      reverse.index(&block)
    else
      reverse.index(val, &block)
    end
  end

  def rotate(count = 1)
    ary = []
    len = length

    return ary unless len.positive?

    # rotate count
    idx =
      if count.negative?
        (len - (~count % len) - 1)
      else
        (count % len)
      end
    len.times do
      ary << self[idx]
      idx += 1
      idx = 0 if idx > len - 1
    end
  end

  def rotate!(count = 1)
    replace(rotate(count))
  end

  # Returns one or more randomly-chosen elements from `self` using the
  # `Kernel#rand`-compatible random source. With no argument, returns a
  # single element (or `nil` for an empty array). With an integer `n`,
  # returns an Array of up to `n` distinct elements (fewer if the
  # receiver has fewer elements).
  #
  # Matches ruby/spec `core/array/sample_spec.rb` for the integer-arity
  # forms. The `random:` / options-hash keyword surface is accepted for
  # arity parity with CRuby but still routes through `Kernel#rand`;
  # plugging in a user-supplied `Random` instance will follow once the
  # Random core class is wired up.
  def sample(*args)
    # No arguments: return a single element uniformly.
    if args.empty?
      len = length
      return nil if len.zero?

      return self[rand(len)]
    end

    raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0..2)" if args.length > 2

    count_arg = args[0]
    options = args[1]
    raise TypeError, "no implicit conversion of #{options.class} into Hash" if options && !options.is_a?(Hash)

    count =
      if count_arg.is_a?(Integer)
        count_arg
      elsif count_arg.respond_to?(:to_int)
        converted = count_arg.to_int
        unless converted.is_a?(Integer)
          raise TypeError,
                "can't convert #{count_arg.class} to Integer (#{count_arg.class}#to_int gives #{converted.class})"
        end
        converted
      else
        raise TypeError, "no implicit conversion of #{count_arg.class} into Integer"
      end

    raise ArgumentError, 'negative sample number' if count.negative?
    return [] if count.zero?

    len = length
    return [] if len.zero?

    # Clamp: you can't sample more distinct elements than the array holds.
    count = len if count > len

    # Partial Fisher-Yates: pull `count` elements without replacement by
    # swapping the picked element to the "used" tail of a mutable copy.
    pool = dup
    result = Array.new(count)
    i = 0
    while i < count
      pick = rand(len - i)
      result[i] = pool[pick]
      pool[pick] = pool[len - i - 1]
      i += 1
    end
    result
  end

  def select(&block)
    return to_enum :select unless block

    dup.tap { |ary| ary.select!(&block) }
  end

  def select!(&block)
    return to_enum :select! unless block
    raise FrozenError, "can't modify frozen Array" if frozen?

    result = []
    idx = 0
    skipped = false
    while idx < length
      elem = self[idx]
      if block.call(elem)
        result << elem
      else
        skipped = true
      end
      idx += 1
    end
    return nil unless skipped

    replace(result)
  end

  def shuffle(random: (not_set = true))
    random = Random::DEFAULT if not_set
    shuffled_orders = (0...size).map { |idx| [random.rand, idx] }.sort { |a, b| a[0] <=> b[0] }
    shuffled_orders.map { |_n, idx| idx }.map do |idx|
      self[idx]
    end
  end

  def shuffle!(random: (not_set = true))
    raise FrozenError, "can't modify frozen Array" if frozen?
    return self if length <= 1

    self[0, length] =
      if not_set
        shuffle
      else
        shuffle(random: random)
      end
    self
  end

  def slice!(*args)
    case args.length
    when 1
      arg = range = index = args[0]
      case arg
      when Range
        start = range.begin
        raise TypeError, "No implicit conversion of #{start.class} into Integer" unless start.is_a?(Integer)

        len = range.size
        return nil if start.abs > length

        start += length if start.negative?
        len = length - start if start + len > length

        slice = self[start, len]
        self[start, len] = []
        slice
      when Integer
        return nil if index.abs > length

        index += length if index.negative?

        delete_at(index)
      else
        raise TypeError, "No implicit conversion of #{arg.class} into Integer"
      end
    when 2
      start = args[0]
      len = args[1]
      raise TypeError, "No implicit conversion of #{start.class} into Integer" unless start.is_a?(Integer)
      raise TypeError, "No implicit conversion of #{len.class} into Integer" unless len.is_a?(Integer)

      return nil if start.abs > length

      start += length if start.negative?
      len = length - start if start + len > length

      slice = self[start, len]
      self[start, len] = []
      slice
    else
      raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 1..2)"
    end
  end

  def sort(&block)
    return dup if length <= 1

    block ||= ->(a, b) { a <=> b }
    if length == 2
      l = self[0]
      r = self[1]
      begin
        cmp = block.call(l, r)
        return dup if cmp <= 0
        return reverse if cmp > 0 # rubocop:disable Style/NumericPredicate
      rescue StandardError
        raise ArgumentError, "comparison of #{l.class} with #{r.class} failed"
      end
      raise ArgumentError, "comparison of #{l.class} with #{r.class} failed"
    end

    ary = dup
    middle = (ary.length / 2).to_i
    left = ary[0...middle].sort(&block)
    right = ary[middle..-1].sort(&block)

    # merge
    result = []
    until left.empty? || right.empty?
      # change the direction of this comparison to change the direction of the sort
      l = left[0]
      r = right[0]

      begin
        cmp = block.call(l, r)
        result <<
          if cmp <= 0
            left.shift
          elsif cmp > 0 # rubocop:disable Style/NumericPredicate
            right.shift
          else
            raise ArgumentError, "comparison of #{l.class} with #{r.class} failed"
          end
      rescue StandardError
        raise ArgumentError, "comparison of #{l.class} with #{r.class} failed"
      end
    end
    result + left + right
  end

  def sort!(&block)
    raise FrozenError, "can't modify frozen Array" if frozen?
    return self if length <= 1

    self[0, length] = sort(&block)
    self
  end

  def sort_by!(&block)
    raise FrozenError, "can't modify frozen Array" if frozen?
    return to_enum(:sort_by!) unless block
    return self if length <= 1

    sort! { |left, right| block.call(left) <=> block.call(right) }
  end

  def sum(init = 0, &block)
    idx = 0
    sum = init
    while idx < length
      item = self[idx]
      item = block.call(item) if block

      classname = item.class
      classname = item.inspect if item.equal?(true) || item.equal?(false) || item.nil?
      raise TypeError, "#{classname} can't be coerced into Integer" unless item.respond_to?(:to_i)

      item = item.to_i
      raise TypeError, "#{classname} can't be coerced into Integer" unless item.is_a?(Integer)

      sum += item
      idx += 1
    end
    sum
  end

  def to_a
    return self if instance_of?(Array)

    [].concat(self)
  end

  def to_ary
    self
  end

  def to_h(&blk)
    h = {}
    idx = 0
    len = length
    while idx < len
      v = self[idx]
      v = blk.call(v) if blk
      v =
        if v.is_a?(Array)
          v
        elsif v.respond_to?(:to_ary)
          val = v.to_ary
          unless v.is_a?(Array)
            raise TypeError, "can't convert #{v.class} to Array (#{v.class}#to_ary gives #{val.class})"
          end

          val
        else
          raise TypeError, "wrong element type #{v.class} at #{idx} (expected array)"
        end

      raise ArgumentError, "wrong array length at #{idx} (expected 2, was #{v.length})" unless v.length == 2

      key, value = *v
      h[key] = value
      idx += 1
    end
    h
  end

  def transpose
    return [] if empty?

    column_count = nil
    each do |row|
      raise TypeError unless row.is_a?(Array)

      column_count ||= row.count
      raise IndexError, 'element size differs' unless column_count == row.count
    end

    Array.new(column_count) do |column_index|
      map { |row| row[column_index] }
    end
  end

  def union(*args)
    ary = dup
    args.each do |x|
      ary.concat(x)
      ary.uniq!
    end
    ary
  end

  def uniq(&block)
    dup.tap { |ary| ary.uniq!(&block) }
  end

  def uniq!(&block)
    hash = {}
    if block
      each do |val|
        key = block.call(val)
        hash[key] = val unless hash.key?(key)
      end
      result = hash.values
    else
      hash = {}
      each do |val|
        hash[val] = val
      end
      result = hash.keys
    end
    if result.size == size
      nil
    else
      replace(result)
    end
  end

  def unshift(*args)
    self[0, 0] = args
    self
  end

  def values_at(*selectors)
    ary = []
    idx = 0
    len = selectors.length
    while idx < len
      selector = selectors[idx]
      case selector
      when Integer
        ary << self[selector]
      when Range
        ary.concat(self[selector])
      else
        classname = selector.class
        classname = selector.inspect if selector.equal?(true) || selector.equal?(false) || selector.nil?
        raise TypeError, "No implicit conversion from #{classname} to Integer" unless selector.respond_to?(:to_int)

        selector = selector.to_int
        unless selector.is_a?(Integer)
          raise TypeError, "can't convert #{classname} to Integer (#{classname}#to_int gives #{selector.class})"
        end

        ary << self[selector]
      end
      idx += 1
    end
    ary
  end

  # Returns an array of tuples pairing elements of `self` with elements at
  # the corresponding index of each argument. Missing values are padded with
  # `nil`. If a block is given, yields each tuple and returns `nil`.
  #
  # Arguments are coerced with `#to_ary` if possible; otherwise, if they
  # respond to `#each`, they are materialised via iteration. This mirrors
  # `Enumerable#zip` / ruby/spec `core/array/zip_spec.rb`.
  def zip(*others, &block)
    # Coerce each argument into an Array. Per spec, `#to_ary` is tried first,
    # and any object that doesn't respond is fed through `#each`.
    arrays = others.map do |other|
      if other.is_a?(Array)
        other
      elsif other.respond_to?(:to_ary)
        converted = other.to_ary
        unless converted.is_a?(Array)
          classname = other.class
          raise TypeError,
                "can't convert #{classname} to Array (#{classname}#to_ary gives #{converted.class})"
        end
        converted
      elsif other.respond_to?(:each)
        # Materialise the iterable. `Array#zip` consumes "lazily" in CRuby,
        # stopping at `self.length`, so we only pull as many as we need.
        collected = []
        limit = length
        other.each do |item|
          break if collected.length >= limit

          collected << item
        end
        collected
      else
        classname = other.class
        raise TypeError, "wrong argument type #{classname} (must respond to :each)"
      end
    end

    if block
      idx = 0
      len = length
      while idx < len
        tuple = [self[idx]]
        arrays.each { |arr| tuple << arr[idx] }
        block.call(tuple)
        idx += 1
      end
      nil
    else
      result = []
      idx = 0
      len = length
      while idx < len
        tuple = [self[idx]]
        arrays.each { |arr| tuple << arr[idx] }
        result << tuple
        idx += 1
      end
      result
    end
  end

  def |(other)
    raise TypeError, "can't convert #{other.class} into Array" unless other.is_a?(Array)

    ary = self + other
    ary.uniq! || ary
  end

  alias append push
  alias map collect
  alias map! collect!
  alias prepend unshift
  alias slice []
  alias take drop
  alias take_while drop_while
  alias to_s inspect
end
