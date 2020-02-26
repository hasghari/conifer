# frozen_string_literal: true

require 'yaml'
require 'erb'

module Conifer
  class File
    NotFoundError = Class.new(StandardError)

    attr_reader :name, :prefix, :dir

    def initialize(name, dir:, prefix: nil)
      @name = name
      @prefix = prefix
      @dir = dir
    end

    def [](key)
      args = key.split('.').tap { |v| v.prepend(prefix) if prefix }
      parsed.dig(*args)
    end

    def parsed
      @parsed ||= YAML.safe_load(ERB.new(::File.read(path)).result)
    end

    def path
      return @path if defined? @path

      @path = find_path
    end

    def exists?
      !path.nil?
    end

    def filename
      "#{::File.basename(name.to_s, '.yml')}.yml"
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
