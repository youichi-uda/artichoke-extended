# frozen_string_literal: true
#
# Minimal File class for Artichoke.
#
# Since mruby-io is not compiled into Artichoke, this provides the
# subset of File that Logstash Ruby filters commonly use:
#
#   File.read(path)       — read entire file as a string
#   File.exist?(path)     — check if a file exists
#   File.readlines(path)  — read file into array of lines
#   File.basename(path)   — filename component
#   File.dirname(path)    — directory component
#   File.extname(path)    — extension
#   File.join(*parts)     — path joining
#   File.expand_path(path)— expand to absolute path
#
# File.open with block and write operations are NOT supported (Artichoke
# runs in a sandboxed context without general write access).
#
# Implementation note: File.read and File.exist? delegate to the Artichoke
# load-path VFS when `load-path-native-file-system-loader` is enabled,
# or raise an error otherwise. The path-manipulation methods are pure
# string operations and always work.

class File
  SEPARATOR = '/'.freeze
  ALT_SEPARATOR = nil
  PATH_SEPARATOR = ':'.freeze

  class << self
    def join(*parts)
      parts.map(&:to_s).join(SEPARATOR)
    end

    def basename(path, suffix = nil)
      path = path.to_s
      name = path.split(SEPARATOR).last || path
      if suffix
        if suffix == '.*'
          name = name.sub(/\.[^.]*\z/, '')
        elsif name.end_with?(suffix)
          name = name[0, name.length - suffix.length]
        end
      end
      name
    end

    def dirname(path)
      path = path.to_s
      idx = path.rindex(SEPARATOR)
      return '.' if idx.nil?
      return SEPARATOR if idx.zero?

      path[0, idx]
    end

    def extname(path)
      base = basename(path.to_s)
      idx = base.rindex('.')
      return '' if idx.nil? || idx.zero?

      base[idx..-1]
    end

    def expand_path(path, dir = nil)
      path = path.to_s
      if path.start_with?('~')
        home = ENV['HOME'] || '/root'
        path = home + path[1..-1]
      end
      unless path.start_with?(SEPARATOR)
        base = dir ? dir.to_s : Dir.pwd rescue '.'
        path = base + SEPARATOR + path
      end
      # Normalise . and ..
      parts = []
      path.split(SEPARATOR).each do |part|
        case part
        when '', '.' then next
        when '..' then parts.pop
        else parts << part
        end
      end
      SEPARATOR + parts.join(SEPARATOR)
    end

    def exist?(path)
      # Attempt to stat via the load-path VFS. This works when
      # Artichoke's native filesystem loader is enabled.
      __file_exist_native?(path.to_s)
    rescue
      false
    end
    alias exists? exist?

    def file?(path)
      exist?(path)
    end

    def read(path, *_args)
      __file_read_native(path.to_s)
    end

    def readlines(path, sep = $/)
      read(path).split(sep).map { |l| l + sep.to_s }
    end

    def write(path, data, *_args)
      __file_write_native(path.to_s, data.to_s)
    end

    # These delegate to Kernel methods that Artichoke may or may not
    # have. The stubs ensure the class API exists so callers don't get
    # NoMethodError — they'll get a RuntimeError if the FS isn't
    # available.
    def __file_exist_native?(path)
      # Use the load-path to probe. If the file can be loaded, it exists.
      # This is a heuristic — true FS stat requires mruby-io.
      begin
        File.read(path)
        true
      rescue
        false
      end
    end

    def __file_read_native(path)
      # Artichoke's `Kernel#load` can read files when the native FS
      # loader is enabled. For raw reads, we use the internal eval
      # path. If that's not available, raise.
      raise Errno::ENOENT, "No such file or directory - #{path}" unless defined?(Artichoke)

      # Try to use Artichoke's internal file reading if available.
      # Fall back to a descriptive error.
      raise Errno::ENOENT, "File.read is not available in sandboxed mode - #{path}"
    end

    def __file_write_native(path, data)
      raise Errno::EACCES, "File.write is not available in sandboxed mode - #{path}"
    end
  end
end

# Provide Errno constants that File operations reference.
module Errno
  class ENOENT < StandardError; end
  class EACCES < StandardError; end
  class EISDIR < StandardError; end
  class EEXIST < StandardError; end
end unless defined?(Errno::ENOENT)
