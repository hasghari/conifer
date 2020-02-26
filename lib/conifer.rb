# frozen_string_literal: true

require 'conifer/version'
require 'conifer/file'

module Conifer
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def conifer(name, prefix: nil, dir: nil, method: ::File.basename(name.to_s, '.yml'), singleton: false)
      dir ||= ::File.expand_path(::File.dirname(caller_locations.first.path))

      body = proc do
        return instance_variable_get("@conifer_#{method}") if instance_variable_defined?("@conifer_#{method}")

        instance_variable_set "@conifer_#{method}", Conifer::File.new(name, prefix: prefix, dir: dir).tap(&:validate!)
      end

      if singleton
        define_singleton_method method, &body
      else
        define_method method, &body
      end
    end
  end
end
