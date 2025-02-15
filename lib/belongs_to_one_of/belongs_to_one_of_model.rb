# frozen_string_literal: true

module BelongsToOneOf
  class BelongsToOneOfModel
    class InvalidParamsException < ArgumentError; end

    def initialize(
      resource_key,
      raw_possible_resource_types,
      include_type_column,
      resource_type_field,
      model_class
    )
      @resource_key = resource_key
      @possible_resource_types = normalise_resource_types(raw_possible_resource_types)
      @include_type_column = include_type_column
      @resource_type_field = resource_type_field
      @model_class = model_class
      validate_config
      initialize_associations
    end

    attr_reader :resource_key, :possible_resource_types, :include_type_column,
                :resource_type_field, :model_class

    # TODO: I18n the error messages (provide translations??)
    def validate_exactly_one_resource(model)
      return if number_of_resources(model) == 1

      model.errors.add(:base, "model must belong to exactly one #{resource_key}")
    end

    def validate_at_most_one_resource(model)
      return unless number_of_resources(model) > 1

      model.errors.add(:base, "model must belong to at most one #{resource_key}")
    end

    def validate_correct_resource_type(model)
      resource = model.send(resource_key)
      return unless resource

      actual_resource_type = resource_type_getter(model)
      specified_resource_type = model.send(resource_type_field)

      unless actual_resource_type == specified_resource_type
        model.errors.add(
          resource_type_field,
          "#{resource_type_field} must match the type of #{resource_key}",
        )
      end
    end

    def resource_setter(resource, model)
      return if resource.nil?

      possible_resource_types.each_key do |resource_type|
        model.public_send(:"#{resource_type}=", nil)
      end

      model.instance_variable_set(:"@#{resource_key}", resource)
      resource_type_accessor = find_resource_accessor(resource, model)

      unless resource_type_accessor
        message = "one of #{possible_resource_types.keys.join(', ')} expected, " \
                  "got #{resource.inspect} which is an instance of " \
                  "#{resource.class}(##{resource.class.object_id})"
        raise ActiveRecord::AssociationTypeMismatch, message
      end

      resource_setter_method = "#{resource_type_accessor}="
      model.public_send(resource_setter_method, resource)

      if include_type_column
        resource_type_setter_method = "#{resource_type_field}="
        resource_type_to_store = find_resource_type(resource, model)
        model.public_send(resource_type_setter_method, resource_type_to_store)
      end
    end

    def resource_getter(model)
      possible_resource_types.keys.detect do |resource_type|
        return model.send(resource_type) if model.send(resource_type)
      end
    end

    def resource_id_getter(model)
      possible_resource_types.values.detect do |id_column|
        return model.send(id_column) if model.send(id_column)
      end
    end

    def resource_type_getter(model)
      resource = model.send(resource_key)
      return unless resource

      possible_resource_types.keys.detect do |resource_type_accessor|
        reflection = model.class.reflect_on_association(resource_type_accessor)
        return reflection.class_name if resource.is_a?(reflection.klass)
      end
    end

    private

    def validate_config
      unless resource_key.is_a?(Symbol)
        raise InvalidParamsException,
              "expected resource_key to be a symbol, received #{resource_key.class}"
      end
    end

    def initialize_associations
      possible_resource_types.each do |resource_type_accessor, resource_id_column|
        opts = { optional: true }

        # Only set :foreign_key for a complex relation. Simple relations can be safely
        # "inflected" (i.e. Rails knows these objects are the same...)
        #   foo = Foo.find(1)
        #   foo.bar.foo == foo
        if resource_id_column.to_s.gsub!(/_id$/, "") != resource_type_accessor.to_s
          opts[:foreign_key] = resource_id_column
        end

        model_class.belongs_to(resource_type_accessor, **opts)
      end
    end

    def normalise_resource_types(raw_possible_resource_types)
      if raw_possible_resource_types.is_a?(Array)
        raw_possible_resource_types.each_with_object({}) do |classname, hash|
          unless classname.is_a?(Symbol)
            raise InvalidParamsException, "expected a symbol, received #{classname}"
          end

          hash[classname] = :"#{classname.to_s.underscore}_id"
        end
      elsif raw_possible_resource_types.is_a?(Hash)
        raw_possible_resource_types
      else
        raise InvalidParamsException,
              "possible_resource_types must be an Array or a Hash, " \
              "received #{raw_possible_resource_types.class}"
      end
    end

    def number_of_resources(model)
      possible_resource_types.keys.count do |resource_type_accessor|
        model.send(resource_type_accessor)
      end
    end

    def find_resource_accessor(resource, model)
      possible_resource_types.keys.detect do |resource_type_accessor|
        reflection = model.class.reflect_on_association(resource_type_accessor)
        return resource_type_accessor if resource.is_a?(reflection.klass)
      end
    end

    def find_resource_type(resource, model)
      possible_resource_types.keys.detect do |resource_type_accessor|
        reflection = model.class.reflect_on_association(resource_type_accessor)
        return reflection.class_name if resource.is_a?(reflection.klass)
      end
    end
  end
end
