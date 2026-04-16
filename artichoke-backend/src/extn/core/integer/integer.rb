# frozen_string_literal: true

class Integer
  include Comparable

  def ceil
    self
  end

  def floor
    self
  end

  def dup
    self
  end

  def to_int
    self
  end

  def odd?
    self % 2 != 0
  end

  def even?
    self % 2 == 0
  end

  def zero?
    self == 0
  end

  def nonzero?
    self == 0 ? nil : self
  end

  def abs
    self < 0 ? -self : self
  end
  alias magnitude abs

  # Ruby 2.1+: Returns an array of digits in the given base (default 10),
  # least significant digit first. `1234.digits == [4, 3, 2, 1]`.
  def digits(base = 10)
    raise ArgumentError, "invalid radix #{base}" if base < 2
    raise Math::DomainError, 'out of domain' if self < 0 # CRuby behaviour
    return [0] if self == 0

    n = self
    result = []
    while n > 0
      result << (n % base)
      n /= base
    end
    result
  end

  # Ruby 2.4+: Returns true if the integer is positive.
  def positive?
    self > 0
  end

  # Ruby 2.4+: Returns true if the integer is negative.
  def negative?
    self < 0
  end

  # Greatest common divisor.
  def gcd(other)
    a = self.abs
    b = other.to_i.abs
    while b != 0
      a, b = b, a % b
    end
    a
  end

  # Least common multiple.
  def lcm(other)
    other = other.to_i
    return 0 if self == 0 || other == 0

    (self * other).abs / gcd(other)
  end

  # Integer exponentiation. `pow(exp)` returns `self ** exp`.
  # `pow(exp, mod)` returns `(self ** exp) % mod`.
  def pow(exp, mod = nil)
    if mod
      base = self % mod
      result = 1
      exp.times { result = (result * base) % mod }
      result
    else
      self ** exp
    end
  end

  alias round floor
  alias truncate floor
end
