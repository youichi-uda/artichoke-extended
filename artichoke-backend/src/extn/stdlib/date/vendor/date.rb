# frozen_string_literal: true
#
# Minimal Date / DateTime implementation for Artichoke.
#
# Covers the API surface that Logstash Ruby filters actually use:
#   Date.parse, Date.today, Date.new, #year, #month, #day, #wday,
#   #yday, #strftime, #to_s, #+, #-, #<=>, #==, Date#to_time,
#   DateTime.parse, DateTime.now, DateTime#hour, #min, #sec, #to_time.
#
# Backed by the existing Time class for all calendar arithmetic.

class Date
  include Comparable

  ABBR_DAYNAMES  = %w[Sun Mon Tue Wed Thu Fri Sat].freeze
  DAYNAMES       = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
  ABBR_MONTHNAMES = [nil, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].freeze
  MONTHNAMES     = [nil, 'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'].freeze

  attr_reader :year, :month, :day

  def initialize(year = -4712, month = 1, day = 1)
    @year  = year.to_i
    @month = month.to_i
    @day   = day.to_i
    __validate!
  end

  # --- Class methods ---

  def self.today
    t = Time.now
    new(t.year, t.month, t.day)
  end

  def self.parse(str)
    s = str.to_s.strip
    # ISO 8601: 2026-04-16
    if s =~ /\A(\d{4})-(\d{1,2})-(\d{1,2})/
      return new($1.to_i, $2.to_i, $3.to_i)
    end
    # Slash format: 2026/04/16 or 04/16/2026
    if s =~ %r{\A(\d{4})/(\d{1,2})/(\d{1,2})}
      return new($1.to_i, $2.to_i, $3.to_i)
    end
    if s =~ %r{\A(\d{1,2})/(\d{1,2})/(\d{4})}
      return new($3.to_i, $1.to_i, $2.to_i)
    end
    # "16 Apr 2026" / "Apr 16, 2026"
    months = { 'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4,
               'may' => 5, 'jun' => 6, 'jul' => 7, 'aug' => 8,
               'sep' => 9, 'oct' => 10, 'nov' => 11, 'dec' => 12 }
    if s =~ /\A(\d{1,2})\s+(\w{3})\s+(\d{4})/
      m = months[$2.downcase]
      return new($3.to_i, m, $1.to_i) if m
    end
    if s =~ /\A(\w{3})\s+(\d{1,2}),?\s+(\d{4})/
      m = months[$1.downcase]
      return new($3.to_i, m, $2.to_i) if m
    end
    # "20260416" compact
    if s =~ /\A(\d{4})(\d{2})(\d{2})\z/
      return new($1.to_i, $2.to_i, $3.to_i)
    end
    raise ArgumentError, "invalid date: #{str.inspect}"
  end

  def self.civil(y, m = 1, d = 1)
    new(y, m, d)
  end

  def self.jd(jd)
    # Julian Day → Gregorian calendar (algorithm from Meeus)
    l = jd + 68569
    n = (4 * l) / 146097
    l = l - (146097 * n + 3) / 4
    i = (4000 * (l + 1)) / 1461001
    l = l - (1461 * i) / 4 + 31
    j = (80 * l) / 2447
    d = l - (2447 * j) / 80
    l = j / 11
    m = j + 2 - 12 * l
    y = 100 * (n - 49) + i + l
    new(y, m, d)
  end

  # --- Instance methods ---

  def wday
    to_time.wday
  end

  def yday
    to_time.yday
  end

  def mday
    @day
  end

  def mon
    @month
  end

  def to_s
    y = @year.to_s.rjust(4, '0')
    m = @month.to_s.rjust(2, '0')
    d = @day.to_s.rjust(2, '0')
    "#{y}-#{m}-#{d}"
  end

  def inspect
    "#<Date: #{to_s}>"
  end

  def to_time
    Time.utc(@year, @month, @day)
  end

  def jd
    # Gregorian → Julian Day Number
    a = (14 - @month) / 12
    y = @year + 4800 - a
    m = @month + 12 * a - 3
    @day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
  end

  def strftime(format)
    to_time.strftime(format)
  end

  def +(n)
    t = to_time + (n.to_i * 86400)
    self.class.new(t.year, t.month, t.day)
  end

  def -(other)
    if other.is_a?(Date)
      jd - other.jd
    else
      self + (-other.to_i)
    end
  end

  def <=>(other)
    return nil unless other.is_a?(Date)

    jd <=> other.jd
  end

  def ==(other)
    return false unless other.is_a?(Date)

    @year == other.year && @month == other.month && @day == other.day
  end

  def hash
    [self.class, @year, @month, @day].hash
  end

  def eql?(other)
    self == other
  end

  def succ
    self + 1
  end
  alias next succ

  def >>(n)
    m = @month + n.to_i
    y = @year + (m - 1) / 12
    m = (m - 1) % 12 + 1
    d = [@day, __days_in_month(y, m)].min
    self.class.new(y, m, d)
  end

  def <<(n)
    self >> (-n)
  end

  def sunday?;    wday == 0; end
  def monday?;    wday == 1; end
  def tuesday?;   wday == 2; end
  def wednesday?; wday == 3; end
  def thursday?;  wday == 4; end
  def friday?;    wday == 5; end
  def saturday?;  wday == 6; end

  def leap?
    Date.__leap?(@year)
  end

  def self.__leap?(y)
    (y % 4).zero? && (!(y % 100).zero? || (y % 400).zero?)
  end

  private

  def __validate!
    raise ArgumentError, "invalid date" if @month < 1 || @month > 12
    raise ArgumentError, "invalid date" if @day < 1 || @day > __days_in_month(@year, @month)
  end

  def __days_in_month(y, m)
    case m
    when 1, 3, 5, 7, 8, 10, 12 then 31
    when 4, 6, 9, 11 then 30
    when 2 then Date.__leap?(y) ? 29 : 28
    end
  end
end

class DateTime < Date
  attr_reader :hour, :min, :sec, :offset

  def initialize(year = -4712, month = 1, day = 1, hour = 0, min = 0, sec = 0, offset = 0)
    super(year, month, day)
    @hour   = hour.to_i
    @min    = min.to_i
    @sec    = sec.to_i
    @offset = offset  # Rational fraction of day in CRuby; we use hours/24.0
  end

  def self.now
    t = Time.now
    new(t.year, t.month, t.day, t.hour, t.min, t.sec)
  end

  def self.parse(str)
    s = str.to_s.strip
    # ISO 8601: 2026-04-16T12:30:45 or with timezone
    if s =~ /\A(\d{4})-(\d{1,2})-(\d{1,2})[T ](\d{1,2}):(\d{2}):(\d{2})/
      return new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
    end
    # Fall back to Date.parse for date-only strings, promoting to DateTime.
    d = Date.parse(str)
    new(d.year, d.month, d.day)
  end

  def to_s
    y = @year.to_s.rjust(4, '0')
    mo = @month.to_s.rjust(2, '0')
    d = @day.to_s.rjust(2, '0')
    h = @hour.to_s.rjust(2, '0')
    mi = @min.to_s.rjust(2, '0')
    s = @sec.to_s.rjust(2, '0')
    "#{y}-#{mo}-#{d}T#{h}:#{mi}:#{s}+00:00"
  end

  def inspect
    "#<DateTime: #{to_s}>"
  end

  def to_time
    Time.utc(@year, @month, @day, @hour, @min, @sec)
  end

  def to_date
    Date.new(@year, @month, @day)
  end

  def strftime(format)
    to_time.strftime(format)
  end
end
