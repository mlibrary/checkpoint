# frozen_string_literal: true

require 'checkpoint/resource/token'
require 'checkpoint/resource/all_of_type'

module Checkpoint
  # A Resource is any application object that should be considered for
  # restricted access.
  #
  # Most commonly, these will be the core domain objects that are created by
  # users ("model instances", to use Rails terminology), but this is not a
  # requirement. A Resource can represent a fixed item in the system such as
  # the administrative password, where there might be a single 'update'
  # permission to change various elements of configuration. It might also be
  # something like a section of a site as set up in a config file.
  #
  # In modeling an application, it is not always obvious whether a concept
  # should be a {Credential} or a {Resource}, so take care to evaluate the
  # options. As an example, consider access to derivatives of a high-quality
  # media object based on subscription level. It may make more sense for a
  # given application to model access to a fixed set of profiles (e.g., mobile,
  # standard, premium) as credentials and named concepts that will appear
  # throughout the codebase. For an application where the profiles are more
  # dynamic, it may make more sense to model them as resources that can be
  # listed and updated by configuration or at runtime, with a fixed set of
  # permissions (e.g., preview, stream, download).
  #
  # Checkpoint does not force this decision to be made in one way for every
  # application, but provides the concepts of permission mapping and resource
  # resolution to accommodate whatever fixed, dynamic, or inherited modeling is
  # most appropriate for the credentials and resources of an application.
  class Resource
    attr_reader :entity

    # Special string to be used when permitting or searching for permits on all
    # types or all resources
    ALL = '(all)'

    # Creates a converter for this entity. Prefer the class method {::[]}.
    def initialize(entity)
      @entity = entity
    end

    # Default conversion from an entity to a Resource.
    #
    # If the entity implements #to_resource, we will delegate to it. Otherwise,
    # we check if the entity implements #resource_type or #resource_id; if so,
    # we use them as the type and id, respectively. If not, we use the
    # entity's class name as the type and call #id for the id. If the entity
    # does not implement any of the ways to supply an #id, an error will be raised.
    def self.from(entity)
      if entity.respond_to?(:to_resource)
        entity.to_resource
      else
        new(entity)
      end
    end

    # Get the captive entity's type.
    #
    # If the entity implements `#to_resource`, we will call that and use the
    # returned resource's type. If not, but it implements `#resource_type`, we
    # will use that. Otherwise, we use the entity's class name.
    #
    # @return [String] the name of the entity's type after calling `#to_s` on it.
    def type
      if entity.respond_to?(:to_resource)
        entity.to_resource.type
      elsif entity.respond_to?(:resource_type)
        entity.resource_type
      else
        entity.class
      end.to_s
    end

    # Get the captive entity's id.
    #
    # If the entity implements `#to_resource`, we will call that and use the
    # returned resource's type. If not, but it implements `#resource_id`, we
    # will use other. Otherwise we call `#id`. If the the entity does not
    # implement any of these methods, we raise a {NoIdentifierError}.
    #
    # @return [String] the entity's ID after calling `#to_s` on it.
    def id
      if entity.respond_to?(:resource_id)
        entity.resource_id
      elsif entity.respond_to?(:id)
        entity.id
      else
        raise NoIdentifierError, "No usable identifier on entity of type: #{entity.class}"
      end.to_s
    end

    # @return [Resource::Token] The token for this resource
    def token
      @token ||= Token.new(type, id)
    end

    # Convert this Resource into a wildcard representing all resources of this
    # type.
    #
    # @see Resource::AllOfType
    # @return [Resource] A Resource of the same type, but for all members
    def all_of_type
      Resource::AllOfType.new(entity)
    end

    # Check whether two Resources refer to the same entity.
    # @param other [Resource] Another Resource to compare with
    # @return [Boolean] true when the other Resource's entity is the same as
    #   determined by comparing them with `#eql?`.
    def eql?(other)
      other.is_a?(Resource) && entity.eql?(other.entity)
    end

    # Check whether two Resources refer to the same entity.
    # @param other [Resource] Another Resource to compare with
    # @return [Boolean] true when the other Resource's entity is the same as
    #   determined by comparing them with `#==`.
    def ==(other)
      other.is_a?(Resource) && entity == other.entity
    end
  end
end
