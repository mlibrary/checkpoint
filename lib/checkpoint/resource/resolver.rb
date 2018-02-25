# frozen_string_literal: true

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
      return [target] if target.is_a?(Resource)
      [Resource.from(target), Resource.wildcard_from(target)]
    end
  end
end
