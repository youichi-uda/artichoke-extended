# frozen_string_literal: true
#
# Minimal Net::HTTP implementation for Artichoke.
#
# Artichoke does not have socket-level I/O, so actual HTTP requests
# cannot be made from within the mruby VM. This module provides the
# class/module structure so that `require 'net/http'` succeeds and
# callers can construct URI/request objects. Actual I/O methods
# (get, post, request) raise a descriptive RuntimeError explaining
# that the operation requires the ferro-stash HTTP enrichment filter
# instead.
#
# For Logstash migration: if your Ruby filter uses Net::HTTP for
# enrichment, switch to ferro-stash's dedicated HTTP filter plugin
# which uses Rust's async HTTP client for better performance and
# connection pooling.

module Net
  class HTTPResponse
    attr_accessor :code, :body, :message

    def initialize(code = '200', body = '', message = 'OK')
      @code = code
      @body = body
      @message = message
    end

    def is_a?(klass)
      return true if klass == Net::HTTPSuccess && @code.to_i >= 200 && @code.to_i < 300

      super
    end
  end

  class HTTPSuccess < HTTPResponse; end
  class HTTPClientError < HTTPResponse; end
  class HTTPServerError < HTTPResponse; end

  class HTTPRequest
    attr_accessor :method, :path, :body
    attr_reader :headers

    def initialize(path, headers = {})
      @path = path
      @headers = headers
      @body = nil
    end

    def []=(key, value)
      @headers[key] = value
    end

    def [](key)
      @headers[key]
    end
  end

  class HTTP
    class Get < HTTPRequest
      def initialize(path, headers = {})
        super
        @method = 'GET'
      end
    end

    class Post < HTTPRequest
      def initialize(path, headers = {})
        super
        @method = 'POST'
      end
    end

    class Put < HTTPRequest
      def initialize(path, headers = {})
        super
        @method = 'PUT'
      end
    end

    class Delete < HTTPRequest
      def initialize(path, headers = {})
        super
        @method = 'DELETE'
      end
    end

    attr_reader :address, :port
    attr_accessor :use_ssl, :read_timeout, :open_timeout

    def initialize(address, port = 80)
      @address = address
      @port = port
      @use_ssl = false
      @started = false
    end

    def self.new(address, port = 80)
      obj = super
      if block_given?
        obj.start
        begin
          yield obj
        ensure
          obj.finish rescue nil
        end
      end
      obj
    end

    def self.get(uri_or_host, path_or_headers = nil, port = nil)
      raise RuntimeError,
            "Net::HTTP.get is not available in Artichoke's sandboxed Ruby " \
            "environment. Use ferro-stash's HTTP filter plugin for " \
            "enrichment lookups."
    end

    def self.get_response(uri)
      raise RuntimeError,
            "Net::HTTP.get_response is not available in Artichoke's " \
            "sandboxed Ruby environment."
    end

    def self.post(uri, data, headers = {})
      raise RuntimeError,
            "Net::HTTP.post is not available in Artichoke's sandboxed " \
            "Ruby environment."
    end

    def self.start(address, port = 80, **opts)
      http = new(address, port)
      http.use_ssl = opts[:use_ssl] if opts.key?(:use_ssl)
      http.start
      if block_given?
        begin
          yield http
        ensure
          http.finish rescue nil
        end
      else
        http
      end
    end

    def start
      @started = true
      self
    end

    def started?
      @started
    end

    def finish
      @started = false
    end

    def request(req)
      raise RuntimeError,
            "Net::HTTP#request is not available in Artichoke's sandboxed " \
            "Ruby environment. For HTTP enrichment in log pipelines, use " \
            "ferro-stash's dedicated HTTP filter/output plugin which " \
            "provides async Rust-based HTTP with connection pooling."
    end

    def get(path, headers = {})
      request(Get.new(path, headers))
    end

    def post(path, data, headers = {})
      req = Post.new(path, headers)
      req.body = data
      request(req)
    end
  end
end
