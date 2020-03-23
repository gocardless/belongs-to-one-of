# frozen_string_literal: true

require "active_record"
require "active_record/associations"
require_relative "belongs_to_one_of/belongs_to_one_of_model"

# We assume that the connected model is called a 'resource', for the purposes of naming variables in this file

module ActiveRecord
  module Associations
    module ClassMethods
      include BelongsToOneOf

      def belongs_to_one_of(resource_key, raw_possible_resource_types, include_type_column: false)
        resource_type_field = [true, false].include?(include_type_column) ? "#{resource_key}_type" : include_type_column

        config_model = BelongsToOneOfModel.new(resource_key, raw_possible_resource_types, include_type_column, resource_type_field, self)

        # validators
        define_method "belongs_to_exactly_one_#{resource_key}" do
          config_model.validate_exactly_one_resource(self)
        end

        define_method "belongs_to_at_most_one_#{resource_key}" do
          config_model.validate_at_most_one_resource(self)
        end

        if include_type_column
          define_method "#{resource_type_field}_matches_#{resource_key}" do
            config_model.validate_correct_resource_type(self)
          end
        end

        # setters
        define_method "#{resource_key}=" do |resource|
          config_model.resource_setter(resource, self)
        end

        # getters
        define_method resource_key do
          config_model.resource_getter(self)
        end

        define_method "#{resource_key}_id" do
          config_model.resource_id_getter(self)
        end

        unless include_type_column
          define_method "#{resource_key}_type" do
            config_model.resource_type_getter(self)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
