# frozen_string_literal: true

require 'conifer/version'
require 'conifer/file'

require 'active_support/concern'

module Conifer
  extend ActiveSupport::Concern

  class_methods do
    def conifer(file, prefix: nil, dir: nil, method: ::File.basename(file.to_s, '.yml'), singleton: false)
      directory = dir || ::File.expand_path(::File.dirname(caller_locations.first.path))

      body = proc do
        return instance_variable_get("@conifer_#{method}") if instance_variable_defined?("@conifer_#{method}")

        instance_variable_set "@conifer_#{method}", Conifer::File.new(file, prefix: prefix, dir: directory)
      end

      if singleton
        define_singleton_method method, &body
      else
        define_method method, &body
      end
    end
  end
end
