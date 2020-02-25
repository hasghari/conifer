# frozen_string_literal: true

require 'conifer/version'
require 'conifer/file'

require 'active_support/all'

module Conifer
  extend ActiveSupport::Concern

  included do
    def conifer
      self.class.__conifer
    end
  end

  class_methods do
    attr_reader :__conifer

    def conifer(file, prefix: nil, dir: nil)
      directory = dir.presence || ::File.expand_path(::File.dirname(caller_locations.first.path))
      @__conifer = Conifer::File.new(file, prefix: prefix, dir: directory)
    end
  end
end
