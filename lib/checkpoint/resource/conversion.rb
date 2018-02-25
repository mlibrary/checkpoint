# frozen_string_literal: true

module Checkpoint
  class Resource
    # Default conversion from an entity to a {Resource].
    #
    # If the entity implements #to_resource, we will delegate to it. Otherwise,
    # we check if the entity implements #resource_type or #resource_id; if so,
    # we use them as the type and id, respectively. If not, we use the
    # entity's class name as the type and call #id for the id. If the entity
    # does not implement any of the ways to supply an #id, an error will be raised.
    class Conversion
      attr_reader :entity

      # Creates a converter for this entity. Prefer the class method {::[]}.
      def initialize(entity)
        @entity = entity
      end

      # Convenience syntax to avoid .new(...).call.
      # Example: (from within the Resource class) Conversion[entity]
      def self.[](entity)
        new(entity).call
      end

      # Convert the bound entity to a resource. If the entity implements
      # #to_resource, call it. Otherwise, use the defaults as implemented by
      # {#type} and {#id}.
      #
      # @return the entity converted to a Resource
      def call
        if entity.respond_to?(:to_resource)
          entity.to_resource
        else
          Resource.new(type, id)
        end
      end

      protected

      def id
        if entity.respond_to?(:resource_id)
          entity.resource_id
        else
          entity.id
        end
      end

      def type
        if entity.respond_to?(:to_resource)
          entity.to_resource.type
        elsif entity.respond_to?(:resource_type)
          entity.resource_type
        else
          entity.class.to_s
        end
      end
    end

    # Default wildcard conversion from an entity to a {Resource}.
    #
    # This implementation uses the base {Conversion} to get the type, but
    # always uses {Resource::ALL} as the id to provide a wilcard Resource.
    class WildcardConversion < Conversion
      def call
        Resource.new(type, Resource::ALL)
      end
    end
  end
end
