# frozen_string_literal: true

module Checkpoint
  # An Agent is an any person or entity that might be granted various
  # permission, such as a user, group, or institution.
  #
  # The application objects that an agent represents may be of any type; this
  # is more of an interface or role than a base class. The important concept is
  # that permits are granted to agents, and that agents may be representative
  # of multiple concrete actors, such as any person affiliated with a given
  # institution or any member of a given group.
  class Agent
    attr_reader :type, :id

    # Create a new Agent representing an actor in an application.
    #
    # @param type [String] the application-determined type of this agent. This
    #   will commonly be 'user' or 'group', but may be anything that identifies
    #   a type of authentication attribute, such as 'account-type'.
    #
    # @param id [String] the application-resolvable identifier for this agent.
    #   This will commonly be username or group ID, but may be any value of an
    #   attribute of this type used to qualify an actor (user).
    def initialize(type, id)
      @type = type
      @id = id
    end

    # @return [String] a token suitable for granting or matching permits for this agent
    def token
      "#{type}:#{id}"
    end

    # @return [String] a URI for this agent, including its type and id
    def to_s
      "agent://#{type}/#{id}"
    end
  end
end
