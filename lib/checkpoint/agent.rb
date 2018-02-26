# frozen_string_literal: true

require 'checkpoint/agent/resolver'
require 'checkpoint/agent/token'

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
    attr_accessor :actor

    # Create an Agent. This should not be called externally; use {::from} instead.
    def initialize(actor)
      @actor = actor
    end

    # Default conversion from an actor to an {Agent}.
    #
    # If the actor implements #to_agent, we will delegate to it. Otherwise,
    # we check if the actor implements #agent_type or #agent_id; if so, we
    # use them as the type and id, respectively. If not, we use the actor's
    # class name as the type and call #id for the id. If the actor does not
    # implement any of the ways to supply an #id, an error will be raised.
    #
    # @return [Agent] the actor converted to an agent
    def self.from(actor)
      if actor.respond_to?(:to_agent)
        actor.to_agent
      else
        new(actor)
      end
    end

    # Get the captive actor's type.
    #
    # If the entity implements `#to_agent`, we will call that and use the
    # returned agent's type. If not, but it implements `#agent_type`, we
    # will use that. Otherwise, we use the actors's class name.
    #
    # @return [String] the name of the actor's type after calling `#to_s` on it.
    def type
      if actor.respond_to?(:agent_type)
        actor.agent_type
      else
        actor.class
      end.to_s
    end

    # Get the captive actor's id.
    #
    # If the entity implements `#to_agent`, we will call that and use the
    # returned agent's id. If not, but it implements `#agent_id`, we
    # will use that. Otherwise, we call `#id`. If the the actor does not
    # implement any of these methods, we raise a {NoIdentifierError}.
    #
    # @return [String] the name of the actor's type after calling `#to_s` on it.
    def id
      if actor.respond_to?(:agent_id)
        actor.agent_id
      elsif actor.respond_to?(:id)
        actor.id
      else
        raise NoIdentifierError, "No usable identifier on actor of type: #{actor.class}"
      end.to_s
    end

    def token
      @token ||= Token.new(type, id)
    end

    # Check whether two Agents refer to the same concrete actor.
    # @param other [Agent] Another Agent to compare with
    # @return [Boolean] true when the other Agent's actor is the same as
    #   determined by comparing them with `#eql?`.
    def eql?(other)
      other.is_a?(Agent) && actor.eql?(other.actor)
    end

    # Check whether two Agents refer to the same concrete actor.
    # @param other [Agent] Another Agent to compare with
    # @return [Boolean] true when the other Agent's actor is the same as
    #   determined by comparing them with `==`.
    def ==(other)
      other.is_a?(Agent) && actor == other.actor
    end
  end
end
