# frozen_string_literal: true

require 'checkpoint/resource'

module Checkpoint
  # A ResourceResolver takes a concrete object (like a model instance) and
  # resolves it into all {Resource}s for which a permit would allow an action.
  # For example, this can be used to grant a credential on all items of a given
  # model class or to implement cascading permissions when all credentials for
  # a container should apply to the contained objects.
  #
  # NOTE: This implementation currently always resolves to the entity and its
  # type and nothing more. This needs some thought on an appropriate extension
  # mechanism to mirror the {PermissionMapper}.
  class ResourceResolver
    def resolve(target)
      [entity_resource(target), wildcard_resource(target)]
    end

    private

    def entity_resource(target)
      if target.respond_to?(:to_resource)
        target.to_resource
      else
        Resource.new(resource_type(target), resource_id(target))
      end
    end

    def wildcard_resource(target)
      Resource.new(resource_type(target), Resource::ALL)
    end

    def resource_id(target)
      if target.respond_to?(:resource_id)
        target.resource_id
      else
        target.id
      end
    end

    def resource_type(target)
      if target.respond_to?(:to_resource)
        target.to_resource.type
      elsif target.respond_to?(:resource_type)
        target.resource_type
      elsif target.respond_to?(:type)
        target.type
      else
        target.class.to_s
      end
    end
  end
end
