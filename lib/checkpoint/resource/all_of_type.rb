# frozen_string_literal: true

module Checkpoint
  class Resource
    # Specialized Resource type to represent all entities of a particular type.
    class AllOfType < Resource
      def self.from(entity)
        if entity.respond_to?(:to_resource)
          new(entity.to_resource)
        else
          new(entity)
        end
      end

      def id
        Resource::ALL
      end
    end
  end
end
