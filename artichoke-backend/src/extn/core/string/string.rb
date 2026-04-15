# frozen_string_literal: true

module Artichoke
  class String
    def self.tr_expand_str(str)
      arr = []
      str_a = str.chars
      i = 0
      while i < str_a.length
        if str_a[i + 1] == '-' && !str_a[i + 2].nil?
          range = (str_a[i]..str_a[i + 2]).to_a
          raise ArgumentError if range.empty?

          range[1] = range[0] if range.length == 1
          range.each do |c|
            arr.push(c)
          end
          i += 3
        else
          arr.push(str_a[i])
          i += 1
        end
      end
      arr
    end

    def self.tr_compose_str(src, container, from, to, skip_double, index_check, retrieve_value)
      previous_char = ''
      src.chars.map do |c|
        index = from.index(c)
        if index_check.call(index)
          proposed_replacement_char = retrieve_value.call(to, index)
          replacement_char = proposed_replacement_char
          replacement_char = '' if skip_double && proposed_replacement_char == previous_char
          previous_char = proposed_replacement_char
          container << replacement_char
        else
          previous_char = ''
          container << c
        end
      end.join
    end

    def self.tr(src, from_str, to_str, skip_double)
      from_str = from_str.to_str
      to_str = to_str.to_str

      result = src.class.new

      if from_str.start_with?('^') && from_str.length > 1
        from_str = from_str[1..-1]
        from = tr_expand_str(from_str)
        to = tr_expand_str(to_str)
        tr_compose_str(src, result, from, to, skip_double, lambda(&:nil?), ->(lookup, _) { lookup.last })
      else
        from = tr_expand_str(from_str)
        to = tr_expand_str(to_str)
        tr_compose_str(src, result, from, to, skip_double, ->(index) { !index.nil? }, ->(lookup, index) { lookup[index] || lookup.last || '' })
      end
      result
    end

    def self.implicit_conversion(target)
      return target if target.is_a?(::String)
      raise TypeError, 'no implicit conversion of nil into String' if target.nil?
      raise TypeError, 'no implicit conversion of Symbol into String' if target.is_a?(Symbol)

      converted = target.to_str
      return converted if converted.is_a?(::String)

      inspect_name = target.class.name
      inspect_name = target.inspect if target.is_a?(TrueClass) || target.is_a?(FalseClass) || target.nil?
      message = "can't convert #{inspect_name} to String (#{inspect_name}#to_str gives #{converted.class})"
      raise TypeError, message
    rescue NoMethodError
      inspect_name = target.class.name
      inspect_name = target.inspect if target.is_a?(TrueClass) || target.is_a?(FalseClass) || target.nil?
      message = "no implicit conversion of #{inspect_name} into String"
      raise TypeError, message
    end
  end
end

# https://ruby-doc.org/core-3.0.2/String.html
class String
  include Comparable

  # https://ruby-doc.org/core-3.0.2/String.html#method-c-new
  #
  # NOTE: Implemented in native code.
  #
  # def self.new(string, **kwargs); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-c-try_convert
  def self.try_convert(obj)
    return nil if obj.nil?
    return obj if obj.is_a?(String)

    str = obj.to_str
    return nil if str.nil?
    return str if str.is_a?(String)

    raise TypeError, "can't convert #{obj.class} to String (#{obj.class}#to_str gives #{str.class})"
  rescue NoMethodError
    nil
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-25
  def %(other)
    if other.is_a?(Array)
      sprintf(self, *other) # rubocop:disable Style/FormatString
    else
      sprintf(self, other) # rubocop:disable Style/FormatString
    end
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-2A
  #
  # NOTE: Implemented in native code.
  #
  # def *(integer); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-2B
  #
  # NOTE: Implemented in native code.
  #
  # def +(other_string); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-2B-40
  def +@
    return dup if frozen?

    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-2D-40
  def -@
    # TODO: check to see if the string does not have any ivars defined on it.
    return self if frozen?

    dup.freeze
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-2F
  alias / split

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-3C-3C
  #
  # NOTE: Implemented in native code.
  #
  # def <<(object); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-3C-3D-3E
  #
  # NOTE: Implemented in native code.
  #
  # def <=>(other_string); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-3D-3D
  #
  # NOTE: Implemented in native code.
  #
  # def ==(other_string); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-3D-3D-3D
  alias === ==

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-3D-7E
  def =~(other)
    # TODO: This implementation does not "also updates Regexp-related global
    # variables" like MRI does.
    return other.match(self)&.begin(0) if other.is_a?(Regexp)
    raise TypeError, "type mismatch: #{other.class} given" if other.is_a?(String)

    other =~ self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-5B-5D
  #
  # NOTE: Implemented in native code.
  #
  # def [](*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-5B-5D-3D
  #
  # NOTE: Implemented in native code.
  #
  # def []=(*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-ascii_only-3F
  #
  # NOTE: Implemented in native code.
  #
  # def ascii_only?; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-b
  #
  # NOTE: Implemented in native code.
  #
  # def b; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-bytes
  #
  # NOTE: Implemented in native code.
  #
  # def bytes; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-bytesize
  #
  # NOTE: Implemented in native code.
  #
  # def bytesize; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-byteslice
  #
  # NOTE: Implemented in native code.
  #
  # def bytesize(integer, *args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-capitalize
  #
  # NOTE: Implemented in native code.
  #
  # def capitalize; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-capitalize-21
  #
  # NOTE: Implemented in native code.
  #
  # def capitalize!; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-casecmp
  #
  # NOTE: Implemented in native code.
  #
  # def casecmp(other_str); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-casecmp-3F
  #
  # NOTE: Implemented in native code.
  #
  # def casecmp?(other_string); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-center
  #
  # NOTE: Implemented in native code.
  #
  # def center(width, padstr=' '); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chars
  #
  # NOTE: Implemented in native code.
  #
  # def chars; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chomp
  #
  # NOTE: Implemented in native code.
  #
  # def chomp(separator=$/); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chomp-21
  #
  # NOTE: Implemented in native code.
  #
  # def chomp!(separator=$/); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chop
  #
  # NOTE: Implemented in native code.
  #
  # def chop; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chop-21
  #
  # NOTE: Implemented in native code.
  #
  # def chop!; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-chr
  #
  # NOTE: Implemented in native code.
  #
  # def chr; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-clear
  #
  # NOTE: Implemented in native code.
  #
  # def clear; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-codepoints
  #
  # NOTE: Implemented in native code.
  #
  # def codepoints; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-concat
  def concat(*objects)
    objects.each do |obj|
      self << obj
    end
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-count
  #
  # Returns the number of characters in `self` that are contained in the
  # intersection of all argument sets. Each argument is a "character set"
  # string with the same parsing rules as `String#tr`:
  #
  #   - A leading `^` negates the set ("every character NOT in ...").
  #     A set consisting of just `"^"` is literal, not a negation.
  #   - `a-z` defines an inclusive byte range, but a literal `-` at the
  #     start or end of the set (or immediately after the `^` negation
  #     marker) is matched literally.
  #   - A backslash `\\` escapes the next character.
  #
  # Raises `ArgumentError` if called with no arguments. Matches ruby/spec
  # `core/string/count_spec.rb`.
  def count(*args)
    raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' if args.empty?

    # Parse each argument into a (negated, lookup_table) tuple. We work on
    # raw bytes so that binary-encoded strings (`"hello\x00\x00"`) behave
    # byte-for-byte, matching the count_spec assertions.
    sets = args.map { |a| String.__parse_char_set(a) }

    bytes = self.bytes
    total = 0
    idx = 0
    len = bytes.length
    while idx < len
      byte = bytes[idx]
      included = true
      set_idx = 0
      set_count = sets.length
      while set_idx < set_count
        negated, lookup = sets[set_idx]
        present = lookup[byte]
        if negated ? present : !present
          included = false
          break
        end
        set_idx += 1
      end
      total += 1 if included
      idx += 1
    end
    total
  end

  # Internal helper for parsing `String#count` / `#tr` / `#squeeze` /
  # `#delete` character-set specifications. Returns `[negated, lookup]`
  # where `lookup` is a 256-entry boolean array indexed by byte value.
  def self.__parse_char_set(spec)
    bytes = spec.bytes
    lookup = Array.new(256, false)

    # A lone `^` is the literal character, not a negation marker.
    negated = bytes.length > 1 && bytes[0] == 0x5E # '^'
    i = negated ? 1 : 0

    # Collect the literal characters into a temporary buffer so that we
    # can decide per-position whether `-` is a range operator or a
    # literal. The spec's rule is: `-` is literal if it's the first or
    # last character in the set (after any negation marker).
    chars = []
    escape_next = false
    while i < bytes.length
      byte = bytes[i]
      if escape_next
        chars << byte
        escape_next = false
        i += 1
        next
      end
      if byte == 0x5C # '\\'
        escape_next = true
        i += 1
        next
      end
      chars << byte
      i += 1
    end

    # Walk `chars` and materialise the set, treating `-` as a range
    # operator only when it has a character both before it and after it.
    j = 0
    first_idx = 0
    last_idx = chars.length - 1
    while j < chars.length
      c = chars[j]
      if c == 0x2D && j != first_idx && j != last_idx # '-'
        start_byte = chars[j - 1]
        end_byte = chars[j + 1]
        if end_byte >= start_byte
          (start_byte..end_byte).each { |b| lookup[b] = true }
        end
        j += 2 # skip past `-` and the end char
        next
      end
      lookup[c] = true
      j += 1
    end

    [negated, lookup]
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-crypt
  def crypt(_salt_str)
    raise NotImplementedError, 'String#crypt uses an insecure algorithm and is deprecated'
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete
  def delete(*args)
    args.inject(self) { |string, pattern| Artichoke::String.implicit_conversion(string).tr(pattern, '') }
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete-21
  def delete!(*args)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = delete(*args)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete_prefix
  def delete_prefix(prefix)
    prefix = Artichoke::String.implicit_conversion(prefix)
    return dup if prefix.empty?

    if start_with?(prefix)
      slice = self[prefix.length..-1]
      return slice if instance_of?(String)

      return self.class.new(slice)
    end
    dup
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete_prefix-21
  def delete_prefix!(prefix)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = delete_prefix(prefix)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete_suffix
  def delete_suffix(suffix)
    suffix = Artichoke::String.implicit_conversion(suffix)
    return dup if suffix.empty?

    if end_with?(suffix)
      slice = self[0...-suffix.length]
      return slice if instance_of?(String)

      return self.class.new(slice)
    end
    dup
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-delete_suffix-21
  def delete_suffix!(prefix)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = delete_suffix(prefix)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-downcase
  #
  # NOTE: Implemented in native code.
  #
  # def downcase; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-downcase-21
  #
  # NOTE: Implemented in native code.
  #
  # def downcase!; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-dump
  #
  # Returns a version of `self` wrapped in double-quotes, with all
  # non-printable and special characters escaped so the result is a
  # valid Ruby string literal that `eval` could reconstruct.
  #
  # Escaping rules (from ruby/spec `core/string/dump_spec.rb`):
  #   - Named escapes for control chars: \a \b \t \n \v \f \r \e
  #   - Backslash and double-quote are escaped: \\ \"
  #   - `#` is escaped only when followed by `$`, `@`, or `{`:
  #     `\#$`, `\#@`, `\#{`
  #   - Printable ASCII (0x20..0x7E) left as-is.
  #   - Everything else: `\xHH` hex notation per byte.
  def dump
    out = '"'.b
    raw = self.b.bytes
    i = 0
    len = raw.length
    while i < len
      b = raw[i]
      case b
      when 0x07 then out << '\\a'
      when 0x08 then out << '\\b'
      when 0x09 then out << '\\t'
      when 0x0A then out << '\\n'
      when 0x0B then out << '\\v'
      when 0x0C then out << '\\f'
      when 0x0D then out << '\\r'
      when 0x1B then out << '\\e'
      when 0x22 then out << '\\"'  # "
      when 0x5C then out << '\\\\' # \
      when 0x23 # '#'
        nxt = raw[i + 1]
        if nxt == 0x24 || nxt == 0x40 || nxt == 0x7B
          out << '\\#'
        else
          out << '#'
        end
      else
        if b >= 0x20 && b <= 0x7E
          out << b.chr
        else
          hi = (b >> 4) & 0x0F
          lo = b & 0x0F
          out << '\\x'
          out << (hi < 10 ? (0x30 + hi).chr : (0x41 + hi - 10).chr)
          out << (lo < 10 ? (0x30 + lo).chr : (0x41 + lo - 10).chr)
        end
      end
      i += 1
    end
    out << '"'
    out.force_encoding(Encoding::UTF_8) if encoding == Encoding::UTF_8
    out
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-each_byte
  def each_byte(&block)
    return to_enum(:each_byte, &block) unless block

    bytes = self.bytes
    pos = 0
    while pos < bytes.size
      block.call(bytes[pos])
      pos += 1
    end
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-each_char
  def each_char(&block)
    return to_enum(:each_char, &block) unless block

    chars = self.chars
    pos = 0
    while pos < chars.size
      block.call(chars[pos])
      pos += 1
    end
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-each_codepoint
  def each_codepoint
    return to_enum(:each_codepoint) unless block_given?

    codepoints = self.codepoints
    pos = 0
    while pos < codepoints.size
      block.call(codepoints[pos])
      pos += 1
    end
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-each_grapheme_cluster
  def each_grapheme_cluster
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-each_line
  def each_line(separator = $/, getline_args = nil) # rubocop:disable Style/SpecialGlobalVars
    return to_enum(:each_line, separator, getline_args) unless block_given?

    if separator.nil?
      yield self
      return self
    end
    raise TypeError if separator.is_a?(Symbol)
    raise TypeError if (separator = String.try_convert(separator)).nil?

    paragraph_mode = false
    if separator.empty?
      paragraph_mode = true
      separator = "\n\n"
    end
    start = 0
    string = dup
    self_len = bytesize
    sep_len = separator.bytesize
    should_yield_subclass_instances = self.class != String

    while (pointer = string.byteindex(separator, start))
      pointer += sep_len
      pointer += 1 while paragraph_mode && string.getbyte(pointer) == 10 # 10 == \n

      slice = string.byteslice(start, pointer - start)
      slice = self.class.new(slice) if should_yield_subclass_instances
      yield slice

      start = pointer
    end
    return self if start == self_len

    slice = string.byteslice(start, self_len - start)
    slice = self.class.new(slice) if should_yield_subclass_instances
    yield slice

    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-empty-3F
  #
  # NOTE: Implemented in native code.
  #
  # def empty?; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-encode
  #
  # TODO: Properly implement this method now that Artichoke has encoding support.
  def encode(*_args)
    # mruby does not support encoding, all Strings are UTF-8. This method is a
    # NOOP and is here for compatibility.
    dup
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-encode-21
  #
  # TODO: Properly implement this method now that Artichoke has encoding support.
  def encode!(*_args)
    # mruby does not support encoding, all Strings are UTF-8. This method is a
    # NOOP and is here for compatibility.
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-encoding
  #
  # TODO: Properly implement this method now that Artichoke has encoding support.
  def encoding
    # mruby does not support encoding, all Strings are UTF-8. This method is a
    # stub and is here for compatibility.
    Encoding::UTF_8
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-end_with-3F
  #
  # NOTE: Implemented in native code.
  #
  # def end_with?; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-eql-3F
  #
  # NOTE: Implemented in native code.
  #
  # def eql?(object); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-force_encoding
  #
  # TODO: Properly implement this method now that Artichoke has encoding support.
  def force_encoding(_encoding)
    # mruby does not support encoding, all Strings are UTF-8. This method is a
    # NOOP and is here for compatibility.
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-freeze
  #
  # NOTE: Implemented in native code.
  #
  # def freeze(); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-getbyte
  #
  # NOTE: Implemented in native code.
  #
  # def getbyte(index); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-grapheme_clusters
  def grapheme_clusters
    each_grapheme_cluster.to_a
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-gsub
  #
  # TODO: Support backrefs
  #
  #   "hello".gsub(/([aeiou])/, '<\1>')             #=> "h<e>ll<o>"
  #   "hello".gsub(/(?<foo>[aeiou])/, '{\k<foo>}')  #=> "h{e}ll{o}"
  def gsub(pattern, replacement = nil)
    return to_enum(:gsub, pattern, replacement) if replacement.nil? && !block_given?

    replace =
      if replacement.nil?
        ->(old) { (yield old).to_s }
      elsif replacement.is_a?(Hash)
        ->(old) { replacement[old].to_s }
      else
        ->(_old) { replacement.to_s }
      end
    pattern = Regexp.compile(Regexp.escape(pattern)) if pattern.is_a?(String)
    match = pattern.match(self)
    return dup if match.nil?

    buf = ''
    remainder = dup
    until match.nil? || remainder.empty?
      buf << remainder[0..(match.begin(0) - 1)] if match.begin(0).positive?
      buf << replace.call(match[0])
      remainder = remainder[match.end(0)..-1]
      remainder = remainder[1..-1] if match.begin(0) == match.end(0)
      match = pattern.match(remainder)
    end
    buf << remainder
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-gsub-21
  def gsub!(pattern, replacement = nil, &blk)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = gsub(pattern, replacement, &blk)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-hash
  #
  # NOTE: Implemented in native code.
  #
  # def hash; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-hex
  #
  # Treats leading characters of `self` as a string of hexadecimal digits
  # (with optional sign and optional `0x`/`0X` prefix) and returns the
  # corresponding number as an Integer. Returns `0` if the conversion fails.
  # Matches ruby/spec `core/string/hex_spec.rb`.
  def hex
    bytes = self.b.bytes
    i = 0
    len = bytes.length

    # Optional sign.
    sign = 1
    if i < len
      case bytes[i]
      when 0x2B # '+'
        i += 1
      when 0x2D # '-'
        sign = -1
        i += 1
      end
    end

    # Optional 0x / 0X prefix.
    if i + 1 < len && bytes[i] == 0x30 && (bytes[i + 1] == 0x78 || bytes[i + 1] == 0x58)
      i += 2
    end

    # There must be at least one hex digit before any underscore.
    return 0 if i >= len

    first = bytes[i]
    hex_digit = (first >= 0x30 && first <= 0x39) || # 0-9
                (first >= 0x41 && first <= 0x46) || # A-F
                (first >= 0x61 && first <= 0x66)    # a-f
    return 0 unless hex_digit

    result = 0
    prev_was_underscore = false
    while i < len
      c = bytes[i]
      if (c >= 0x30 && c <= 0x39)
        result = (result << 4) | (c - 0x30)
        prev_was_underscore = false
        i += 1
      elsif c >= 0x41 && c <= 0x46
        result = (result << 4) | (c - 0x41 + 10)
        prev_was_underscore = false
        i += 1
      elsif c >= 0x61 && c <= 0x66
        result = (result << 4) | (c - 0x61 + 10)
        prev_was_underscore = false
        i += 1
      elsif c == 0x5F # '_'
        # Two underscores in a row terminate the parse. A trailing underscore
        # at the end of the input also terminates.
        break if prev_was_underscore
        break if i + 1 >= len

        nxt = bytes[i + 1]
        is_next_hex = (nxt >= 0x30 && nxt <= 0x39) ||
                      (nxt >= 0x41 && nxt <= 0x46) ||
                      (nxt >= 0x61 && nxt <= 0x66) ||
                      nxt == 0x5F
        break unless is_next_hex

        prev_was_underscore = true
        i += 1
      else
        break
      end
    end

    sign * result
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-include-3F
  #
  # NOTE: Implemented in native code.
  #
  # def include? other_str; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-index
  #
  # NOTE: Implemented in native code.
  #
  # def index(*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-initialize_copy
  #
  # NOTE: Implemented in native code.
  #
  # def replace(other_str); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-insert
  def insert(index, other_str)
    return self << other_str if index == -1

    index += 1 if index.negative?

    self[index, 0] = other_str
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-inspect
  #
  # NOTE: Implemented in native code.
  #
  # def inspect; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-intern
  #
  # NOTE: Implemented in native code.
  #
  # def intern; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-length
  #
  # NOTE: Implemented in native code.
  #
  # def length; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-lines
  def lines(*args)
    each_line(*args).to_a
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-ljust
  def ljust(integer, padstr = ' ')
    raise ArgumentError, 'zero width padding' if padstr == ''

    return self if integer <= length

    pad_repetitions = (integer / padstr.length).ceil
    padding = (padstr * pad_repetitions)[0...(integer - length)]
    "#{self}#{padding}"
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-lstrip
  def lstrip
    strip_pointer = 0
    string_end = length - 1

    # Whitespace is defined as any of the following characters:
    #
    # - null
    # - horizontal tab
    # - line feed
    # - vertical tab
    # - form feed
    # - carriage return
    # - space
    strip_pointer += 1 while strip_pointer <= string_end && "\x00\t\n\v\f\r ".include?(self[strip_pointer])
    return '' if string_end.zero?

    dup[strip_pointer..string_end]
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-lstrip-21
  def lstrip!
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = lstrip
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-match
  def match(pattern, pos = 0)
    pattern = Regexp.compile(Regexp.escape(pattern)) if pattern.is_a?(String)

    pattern.match(self[pos..-1])
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-match-3F
  def match?(pattern, pos = 0)
    pattern = Regexp.compile(Regexp.escape(pattern)) if pattern.is_a?(String)

    # TODO: Don't set $~ and other Regexp globals
    pattern.match?(self[pos..-1])
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-next
  #
  # Returns the successor to `self`, computed by incrementing the
  # rightmost alphanumeric character (digit rolls 0..9, lowercase
  # letter rolls a..z, uppercase letter rolls A..Z). When the
  # increment overflows, the carry propagates left to the next
  # alphanumeric character — non-alphanumerics are passed over
  # untouched. If the carry escapes past the leftmost alphanumeric,
  # a new character of the same class (`1`, `a`, or `A`) is inserted
  # immediately before the position of the leftmost alphanumeric.
  #
  # For strings containing no alphanumerics, the rightmost byte is
  # incremented as an unsigned 8-bit value, with overflow carrying
  # left; if every byte overflows, a `\x01` byte is prepended.
  #
  # Empty strings return an empty string. Matches ruby/spec
  # `core/string/shared/succ.rb`.
  def next
    return dup if empty?

    bytes = self.bytes

    # Walk right-to-left, incrementing alphanumerics and letting any
    # overflow carry through non-alphanumerics to the next alnum to the
    # left. `leftmost_alnum` tracks the position of the most recent
    # alnum we touched so that we know where to insert a fresh digit
    # / letter if the carry falls off the left end.
    leftmost_alnum = nil
    i = bytes.length - 1
    carry = true
    while i >= 0 && carry
      b = bytes[i]
      klass =
        if b >= 0x30 && b <= 0x39 # 0-9
          :digit
        elsif b >= 0x61 && b <= 0x7A # a-z
          :lower
        elsif b >= 0x41 && b <= 0x5A # A-Z
          :upper
        else
          :none
        end

      if klass == :none
        i -= 1
        next
      end

      leftmost_alnum = i

      case klass
      when :digit
        if b == 0x39 # '9' → '0', carry
          bytes[i] = 0x30
        else
          bytes[i] = b + 1
          carry = false
        end
      when :lower
        if b == 0x7A # 'z' → 'a', carry
          bytes[i] = 0x61
        else
          bytes[i] = b + 1
          carry = false
        end
      when :upper
        if b == 0x5A # 'Z' → 'A', carry
          bytes[i] = 0x41
        else
          bytes[i] = b + 1
          carry = false
        end
      end
      i -= 1
    end

    if leftmost_alnum.nil?
      # No alphanumerics at all — increment as bytes.
      return String.__succ_non_alnum(bytes)
    end

    if carry
      # Carry escaped past the leftmost alphanumeric. Insert a fresh
      # character of the same class immediately before it, matching
      # CRuby: `"z".succ == "aa"`, `"Z".succ == "AA"`, `"9".succ == "10"`.
      insert_char =
        case bytes[leftmost_alnum]
        when 0x30 then 0x31 # digit run, prepend '1'
        when 0x61 then 0x61 # lower run, prepend 'a'
        when 0x41 then 0x41 # upper run, prepend 'A'
        else
          0x31
        end
      bytes.insert(leftmost_alnum, insert_char)
    end

    bytes.pack('C*')
  end
  alias succ next

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-next-21
  def next!
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replace(succ)
  end
  alias succ! next!

  # Internal helper for `String#next` on strings that have no
  # alphanumeric characters. Increments the rightmost byte as an
  # unsigned 8-bit value and propagates the carry left; if every byte
  # overflows, prepends a `\x01` byte (matches
  # `"\xFF\xFF".succ == "\x01\x00\x00"`).
  def self.__succ_non_alnum(bytes)
    i = bytes.length - 1
    while i >= 0
      b = bytes[i]
      if b == 0xFF
        bytes[i] = 0x00
        i -= 1
      else
        bytes[i] = b + 1
        return bytes.pack('C*')
      end
    end
    bytes.unshift(0x01)
    bytes.pack('C*')
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-oct
  #
  # Parses a leading integer from `self`. Defaults to base 8, but honours
  # `0b`, `0d`, `0o`, and `0x` prefixes to switch base. Optional sign is
  # accepted before the prefix. Returns `0` on failure. Matches ruby/spec
  # `core/string/oct_spec.rb`.
  def oct
    bytes = self.b.bytes
    i = 0
    len = bytes.length

    # Optional leading whitespace is not stripped by CRuby's oct, but a
    # leading underscore is an error.
    sign = 1
    if i < len
      case bytes[i]
      when 0x2B # '+'
        i += 1
      when 0x2D # '-'
        sign = -1
        i += 1
      end
    end

    # Optional base prefix after optional sign.
    base = 8
    if i + 1 < len && bytes[i] == 0x30
      case bytes[i + 1]
      when 0x62, 0x42 # 'b' / 'B'
        base = 2
        i += 2
      when 0x64, 0x44 # 'd' / 'D'
        base = 10
        i += 2
      when 0x6F, 0x4F # 'o' / 'O'
        base = 8
        i += 2
      when 0x78, 0x58 # 'x' / 'X'
        base = 16
        i += 2
      end
    end

    return 0 if i >= len

    max_digit_char = if base <= 10
                       0x30 + base - 1
                     else
                       0x30 + 9
                     end
    max_letter = base > 10 ? 0x61 + (base - 10 - 1) : nil

    valid_digit = lambda do |c|
      if c >= 0x30 && c <= max_digit_char
        true
      elsif max_letter && c >= 0x61 && c <= max_letter
        true
      elsif max_letter && c >= 0x41 && c <= (0x41 + (base - 10 - 1))
        true
      else
        false
      end
    end

    digit_value = lambda do |c|
      if c >= 0x30 && c <= 0x39
        c - 0x30
      elsif c >= 0x61 && c <= 0x7A
        c - 0x61 + 10
      else
        c - 0x41 + 10
      end
    end

    # Must have at least one valid digit immediately.
    return 0 unless valid_digit.call(bytes[i])

    result = 0
    prev_was_underscore = false
    while i < len
      c = bytes[i]
      if valid_digit.call(c)
        result = result * base + digit_value.call(c)
        prev_was_underscore = false
        i += 1
      elsif c == 0x5F # '_'
        break if prev_was_underscore
        break if i + 1 >= len
        break unless valid_digit.call(bytes[i + 1])

        prev_was_underscore = true
        i += 1
      else
        break
      end
    end

    sign * result
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-ord
  #
  # NOTE: Implemented in native code.
  #
  # def ord; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-partition
  def partition(pattern)
    pattern = Regexp.compile(Regexp.escape(pattern)) if pattern.is_a?(String)

    match = pattern.match(self)
    [match.pre_match, match[0], match.post_match]
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-prepend
  def prepend(*args)
    insert(0, args.join)
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-replace
  #
  # NOTE: Implemented in native code.
  #
  # def replace(other_str); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-reverse
  #
  # NOTE: Implemented in native code.
  #
  # def reverse; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-reverse-21
  #
  # NOTE: Implemented in native code.
  #
  # def reverse!; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-rindex
  #
  # NOTE: Implemented in native code.
  #
  # def rindex(*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-rjust
  def rjust(integer, padstr = ' ')
    raise ArgumentError, 'zero width padding' if padstr == ''

    return self if integer <= length

    pad_repetitions = (integer / padstr.length).ceil
    padding = (padstr * pad_repetitions)[0...(integer - length)]
    "#{padding}#{self}"
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-rpartition
  #
  # Searches the receiver for the last occurrence of `pattern` and returns a
  # three-element array `[head, match, tail]`. If the pattern is not found,
  # returns `["", "", self]` (note the order: the unmatched string lands in
  # the tail position, unlike `partition`, where it lands in the head).
  #
  # Matches ruby/spec `core/string/rpartition_spec.rb`.
  def rpartition(pattern)
    # Duck-type a non-String/Regexp into a String via `#to_str`, matching
    # CRuby's conversion semantics (and the spec's `mock(:to_str)` test).
    if !pattern.is_a?(String) && !pattern.is_a?(Regexp)
      raise TypeError, "no implicit conversion of #{pattern.class} into String" unless pattern.respond_to?(:to_str)

      pattern = pattern.to_str
      raise TypeError, "no implicit conversion of #{pattern.class} into String" unless pattern.is_a?(String)
    end

    if pattern.is_a?(Regexp)
      # `rpartition` picks the match with the LATEST starting offset, which
      # may overlap with an earlier match. `"hello!".rpartition(/l./)` must
      # return the match starting at index 3 ("lo"), not the earlier match
      # starting at index 2 ("ll"). So we step by a single character when
      # scanning, and keep the match with the highest start index.
      last_match = nil
      last_start = -1
      offset = 0
      len = length
      while offset <= len
        md = pattern.match(self, offset)
        break if md.nil?

        start = md.pre_match.length
        if start >= last_start
          last_match = md
          last_start = start
        end
        offset = start + 1
      end
      if last_match.nil?
        return ['', '', dup]
      end

      matched = last_match[0]
      head = self[0, last_start] || ''
      tail = self[(last_start + matched.length)..-1] || ''
      return [head, matched, tail]
    end

    # String pattern: find the last index and split there.
    idx = rindex(pattern)
    return ['', '', dup] if idx.nil?

    head = self[0, idx] || ''
    tail = self[(idx + pattern.length)..-1] || ''
    [head, pattern.dup, tail]
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-rstrip
  def rstrip
    strip_pointer = length - 1
    string_start = 0

    # Whitespace is defined as any of the following characters:
    #
    # - null
    # - horizontal tab
    # - line feed
    # - vertical tab
    # - form feed
    # - carriage return
    # - space
    strip_pointer -= 1 while strip_pointer >= string_start && "\x00\t\n\v\f\r ".include?(self[strip_pointer])
    return '' if strip_pointer.zero?

    dup[string_start..strip_pointer]
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-rstrip-21
  def rstrip!
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = rstrip
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-scan
  #
  # NOTE: Implemented in native code.
  #
  # def scan(pattern, &block); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-scrub
  def scrub
    # TODO: This is a stub. Implement scrub correctly.
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-scrub-21
  def scrub!
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    # TODO: This is a stub. Implement scrub! correctly.
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-setbyte
  #
  # NOTE: Implemented in native code.
  #
  # def setbyte(index, integer); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-size
  #
  # NOTE: Implemented in native code.
  #
  # def length; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-slice
  #
  # NOTE: Implemented in native code.
  #
  # def [](*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-slice-21
  #
  # NOTE: Implemented in native code.
  #
  # def slice!(*args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-split
  #
  # XXX: This should probably be implemented in native code.
  # TODO: Lots of branches are not implemented.
  # TODO: when implemented in native code remove `#[cfg(feature = "regexp")]`
  #       from  `value::tests::funcall_string_split_regexp`.
  def split(pattern = nil, limit = (limit_not_set = true), &block)
    return [] if empty?
    return [dup] if limit == 1

    raise NotImplementedError, 'String#split with block is not supported' unless block.nil?

    limit = -1 if limit_not_set

    if pattern.is_a?(Regexp)
      s = dup
      chunks = []
      until s.empty?
        if limit.positive? && chunks.length == limit - 1
          chunks << s
          return chunks
        end

        match = pattern.match(s)
        if match.nil?
          chunks << s
          return chunks
        end
        chunks << s[0, match.begin(0)]
        advance_to = match.end(0)
        advance_to += 1 if (match.end(0) - match.begin(0)).zero?

        s = s[advance_to..-1]

        return chunks if s.nil?
      end
      return chunks
    end

    pattern = $; if pattern.nil? # rubocop:disable Style/SpecialGlobalVars
    pattern = ' ' if pattern.nil?

    unless pattern.is_a?(String)
      converted = pattern.to_str
      unless converted.is_a?(String)
        raise TypeError, "can't convert #{pattern.class} to String (#{pattern.class}#to_str gives #{converted.class})"
      end

      pattern = converted
    end
    return chars if pattern.empty?

    s = dup
    chunks = []
    until s.empty?
      if limit.positive? && chunks.length == limit - 1
        chunks << s
        return chunks
      end

      index = s.index(pattern)
      if index.nil?
        chunks << s
        return chunks
      end
      chunks << s[0, index]
      s = s[(index + pattern.length)..-1]
    end
    chunks << ''
    chunks
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-squeeze
  def squeeze(*other_str)
    return '' if empty?
    raise NotImplementedError, 'String#squeeze with arguments is not implemented' unless other_str.empty?

    iter = chars
    head, *tail = iter
    runs = [head]
    last_seen = head

    tail.each do |ch|
      next if ch == last_seen

      last_seen = ch
      runs << ch
    end
    runs.join
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-squeeze-21
  def squeeze!(*other_str)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = squeeze(*other_str)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-start_with-3F
  #
  # NOTE: Implemented in native code.
  #
  # def start_with?; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-strip
  def strip
    result = lstrip
    result = self if result.nil?
    result.rstrip
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-strip-21
  def strip!
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = strip
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-sub
  def sub(pattern, replacement = nil)
    return to_enum(:sub, pattern, replacement) if replacement.nil? && !block_given?

    replace =
      if replacement.nil?
        ->(old) { (yield old).to_s }
      elsif replacement.is_a?(Hash)
        ->(old) { replacement[old].to_s }
      else
        ->(_old) { replacement.to_s }
      end
    pattern = Regexp.compile(Regexp.escape(pattern)) if pattern.is_a?(String)
    match = pattern.match(self)
    return dup if match.nil?

    buf = ''
    remainder = dup
    buf << remainder[0..(match.begin(0) - 1)] if match.begin(0).positive?
    buf << replace.call(match[0])
    remainder = remainder[match.end(0)..-1]
    remainder = remainder[1..-1] if match.begin(0) == match.end(0)
    buf << remainder
    buf
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-sub-21
  def sub!(pattern, replacement = nil, &blk)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = sub(pattern, replacement, &blk)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-sum
  #
  # Returns a basic `n_bits`-bit checksum of the bytes in `self`: the
  # raw byte sum folded into `2 ** n_bits`, or the raw byte sum if
  # `n_bits <= 0`. This is the classic BSD `sum(1)`-style checksum —
  # fast and DoS-free, not cryptographic.
  #
  # Matches ruby/spec `core/string/sum_spec.rb`.
  def sum(n_bits = 16)
    n =
      if n_bits.is_a?(Integer)
        n_bits
      elsif n_bits.respond_to?(:to_int)
        converted = n_bits.to_int
        unless converted.is_a?(Integer)
          raise TypeError,
                "can't convert #{n_bits.class} to Integer (#{n_bits.class}#to_int gives #{converted.class})"
        end
        converted
      else
        raise TypeError, "no implicit conversion of #{n_bits.class} into Integer"
      end

    total = 0
    bytes.each { |b| total += b }
    return total if n <= 0

    total & ((1 << n) - 1)
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-swapcase
  #
  # NOTE: Implemented in native code.
  #
  # def swapcase(*_args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-swapcase-21
  #
  # NOTE: Implemented in native code.
  #
  # def swapcase!(*_args); end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_a
  def to_a
    chars
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_c
  def to_c
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_f
  #
  # NOTE: Implemented in native code.
  #
  # def to_f; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_i
  #
  # NOTE: Implemented in native code.
  #
  # def to_i; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_r
  def to_r
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_s
  #
  # NOTE: Implemented in native code.
  #
  # def to_s; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_str
  def to_str
    return self if instance_of?(String)

    String.new(self)
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-to_sym
  #
  # NOTE: Implemented in native code.
  #
  # def to_sym; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-tr
  def tr(from_str, to_str)
    Artichoke::String.tr(self, from_str, to_str, false)
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-tr-21
  def tr!(from_str, to_str)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = tr(from_str, to_str)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-tr_s
  def tr_s(from_str, to_str)
    Artichoke::String.tr(self, from_str, to_str, true)
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-tr_s-21
  def tr_s!(from_str, to_str)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    replaced = tr_s(from_str, to_str)
    replace(replaced) unless self == replaced
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-undump
  def undump
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-unicode_normalize
  def unicode_normalize(_form = :nfc)
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-unicode_normalize-21
  def unicode_normalize!(_form = :nfc)
    raise FrozenError, "can't modify frozen String: #{inspect}" if frozen?

    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-unicode_normalized-3F
  def unicode_normalized?(_form = :nfc)
    raise NotImplementedError
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-unpack
  #
  # NOTE: Implemented in native code.
  #
  # def unpack; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-unpack1
  #
  # NOTE: Implemented in native code in `mruby-pack` mrbgem.
  #
  # def unpack1; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-upcase
  #
  # NOTE: Implemented in native code.
  #
  # def upcase; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-upcase-21
  #
  # NOTE: Implemented in native code.
  #
  # def upcase!; end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-upto
  def upto(max, exclusive = false, &block) # rubocop:disable Style/OptionalBooleanParameter
    return to_enum(:upto, max, exclusive) unless block
    raise TypeError, "no implicit conversion of #{max.class} into String" unless max.is_a?(String)

    len = length
    maxlen = max.length
    # single character
    if len == 1 && maxlen == 1
      c = ord
      e = max.ord
      while c <= e
        break if exclusive && c == e

        yield c.chr
        c += 1
      end
      return self
    end
    # both edges are all digits
    bi = to_i(10)
    ei = max.to_i(10)
    if (bi.positive? || bi == '0' * len) && (ei.positive? || ei == '0' * maxlen)
      while bi <= ei
        break if exclusive && bi == ei

        s = bi.to_s
        s = s.rjust(len, '0') if s.length < len

        yield s
        bi += 1
      end
      return self
    end
    bs = self
    loop do
      n = (bs <=> max)
      break if n.positive?
      break if exclusive && n.zero?

      yield bs
      break if n.zero?

      bs = bs.succ
    end
    self
  end

  # https://ruby-doc.org/core-3.0.2/String.html#method-i-valid_encoding-3F
  #
  # NOTE: Implemented in native code.
  #
  # def valid_encoding?; end
end
