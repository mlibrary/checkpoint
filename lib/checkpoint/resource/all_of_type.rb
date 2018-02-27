# frozen_string_literal: true

module Checkpoint
  class Resource
    # Specialized Resource type to represent all entities of a particular type.
    class AllOfType < Resource
      attr_reader :type
      # Create a wildcard Resource for a given type
      def initialize(type)
        @type = type
      end

      # Create a type-specific wildcard Resource from a given entity
      #
      # When the entity implements to #to_resource, we convert it first and take
      # the type from the result. Otherwise, when it implements #resource_type,
      # we use that result. Otherwise, we take the class name of the entity.
      # Regardless of the source, the type is forced to a string.
      def self.from(entity)
        new(type_of(entity))
      end

      # This is always the special ALL resource ID
      def id
        Resource::ALL
      end

      # Compares with another Resource
      #
      # @return [Boolean] true if `other` is a Resource and its #type matches.
      def eql?(other)
        other.is_a?(Resource) && type == other.type
      end

      # Private type name extraction
      def self.type_of(entity)
        if entity.respond_to?(:to_resource)
          entity.to_resource.type
        elsif entity.respond_to?(:resource_type)
          entity.resource_type
        else
          entity.class
        end.to_s
      end

      private_class_method :type_of
      alias == eql?
    end
  end
end
