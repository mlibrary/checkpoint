# frozen_string_literal: true

module Checkpoint
  class Agent
    # Default conversion from an actor to an {Agent}.
    #
    # If the actor implements #to_agent, we will delegate to it. Otherwise,
    # we check if the actor implements #agent_type or #agent_id; if so, we
    # use them as the type and id, respectively. If not, we use the actor's
    # class name as the type and call #id for the id. If the actor does not
    # implement any of the ways to supply an #id, an error will be raised.
    class Conversion
      attr_reader :actor

      # Creates a converter for this actor. Prefer the class method {::[]}.
      def initialize(actor)
        @actor = actor
      end

      # Convenience syntax to avoid .new(actor).call.
      # Example: (from within the Agent class) Conversion[actor]
      def self.[](actor)
        new(actor).call
      end

      # Convert the bound actor to an agent. If the actor implements #to_agent,
      # call it. Otherwise, use the defaults as implemented by {#type} and {#id}.
      #
      # @return the actor converted to an Agent
      def call
        if actor.respond_to?(:to_agent)
          actor.to_agent
        else
          Agent.new(type, id)
        end
      end

      protected

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
    end
  end
end
