# frozen_string_literal: true

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
    attr_reader :type, :id

    # Create a new Resource representing a domain entity or concept that would
    # be acted upon.
    #
    # @param type [String] the application-determined type of this resource.
    #   This might correspond to a model class or other type of named concept
    #   in the application.
    #
    # @param id [String] the application-resolvable identifier for this
    #   resource. For example, this might be the ID of a model object, the
    #   name of a section .
    def initialize(type, id)
      @type = type
      @id = id
    end

    # @return [String] a token suitable for granting or matching this resource
    def token
      "#{type}:#{id}"
    end

    # @return [String] a URI for this resource, including its type and id
    def to_s
      "resource://#{type}/#{id}"
    end
  end
end
