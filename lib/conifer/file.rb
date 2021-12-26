# frozen_string_literal: true

require 'yaml'
require 'erb'

module Conifer
  class File
    NotFoundError = Class.new(StandardError)
    UnsupportedFormatError = Class.new(StandardError)

    attr_reader :name, :dir, :prefix, :format, :allowed_classes

    def initialize(name, dir:, prefix: nil, format: :yml, allowed_classes: [])
      @name = name
      @dir = dir
      @prefix = prefix
      @format = format
      @allowed_classes = allowed_classes
    end

    def [](key)
      args = key.split('.').tap { |v| v.prepend(prefix) if prefix }
      parsed.dig(*args)
    end

    def parsed
      @parsed ||= case format
                  when :yml, :yaml
                    YAML.safe_load(ERB.new(::File.read(path)).result, permitted_classes: allowed_classes)
                  when :json
                    JSON.parse(ERB.new(::File.read(path)).result)
                  else
                    raise UnsupportedFormatError, "Format '#{format}' is not supported"
                  end
    end

    def path
      return @path if defined? @path

      @path = find_path
    end

    def exists?
      !path.nil?
    end

    def filename
      "#{::File.basename(name.to_s, ".#{format}")}.#{format}"
    end

    def validate!
      raise NotFoundError, "Could not find file #{filename}" if path.nil?
    end

    private

    def find_path(directory = dir)
      file = ::File.join(directory, filename).to_s

      if ::File.exist?(file)
        file
      else
        return if directory == '/'

        find_path(::File.expand_path('..', directory))
      end
    end
  end
end
