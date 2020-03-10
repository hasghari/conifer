# frozen_string_literal: true

require 'conifer/version'
require 'conifer/file'

module Conifer
  def self.included(base)
    base.extend ClassMethods
  end

  # rubocop:disable Metrics/ParameterLists
  module ClassMethods
    def conifer(name, prefix: nil, dir: nil, format: :yml, method: ::File.basename(name.to_s, ".#{format}"),
                singleton: false, allowed_classes: [])
      dir ||= ::File.expand_path(::File.dirname(caller_locations.first.path))

      body = proc do
        return instance_variable_get("@conifer_#{method}") if instance_variable_defined?("@conifer_#{method}")

        instance_variable_set "@conifer_#{method}",
                              Conifer::File.new(name, prefix: prefix, format: format,
                                                      dir: dir, allowed_classes: allowed_classes).tap(&:validate!)
      end

      singleton ? define_singleton_method(method, &body) : define_method(method, &body)
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
