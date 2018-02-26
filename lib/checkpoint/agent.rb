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

    def type
      if actor.respond_to?(:agent_type)
        actor.agent_type
      else
        actor.class.to_s
      end
    end

    def id
      if actor.respond_to?(:agent_id)
        actor.agent_id
      else
        actor.id
      end
    end

    def token
      @token ||= Token.new(type, id)
    end
  end
end
