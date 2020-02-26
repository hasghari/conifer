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
      config.dig(*args)
    end

    def as_hash
      config
    end

    private

    def config
      @config ||= YAML.safe_load(ERB.new(::File.read(path)).result)
    end

    def path(directory = dir)
      file = ::File.join(directory, filename).to_s

      if ::File.exist?(file)
        file
      else
        raise NotFoundError, "Could not find file #{filename}" if directory == '/'

        path(::File.expand_path('..', directory))
      end
    end

    def filename
      "#{::File.basename(name.to_s, '.yml')}.yml"
    end
  end
end
