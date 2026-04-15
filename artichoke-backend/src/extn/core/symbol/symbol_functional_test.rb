# frozen_string_literal: true

def spec
  symbol_encoding
end

########################################
# Symbol#encoding
########################################

def symbol_encoding
  # Always returns a valid Encoding object. Until Artichoke grows
  # real per-symbol encoding tracking, every symbol reports UTF-8 to
  # match `String#encoding`'s stub.
  enc = :hello.encoding
  raise "Expected Encoding, got #{enc.class}" unless enc.is_a?(Encoding)
  raise "Expected UTF-8, got #{enc.inspect}" unless enc == Encoding::UTF_8

  # Symbol#encoding must agree with the equivalent String#encoding,
  # otherwise round-tripping `:foo.to_s.encoding == :foo.encoding`
  # breaks for callers that dispatch on encoding.
  raise 'Expected symbol encoding == string encoding' unless :hello.encoding == 'hello'.encoding

  # Works for multi-byte symbols too. The Artichoke string backend
  # still stores everything as UTF-8, so the symbol form should agree.
  raise 'Expected multibyte symbol encoding to be UTF-8' unless :"こんにちは".encoding == Encoding::UTF_8
end

spec if $PROGRAM_NAME == __FILE__
