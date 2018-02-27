# frozen_string_literal: true

module Checkpoint
  class Agent
    # An Agent Resolver takes a concrete user (or other account/actor) object and
    # resolves it into the set of {Agent}s that the user represents. This has the
    # effect of allowing a Permit to any of those agents to take effect when
    # authorizing an action by this user.
    #
    # This implementation only resolves the user into one agent, using the default
    # conversion.
    #
    # To extend the set of {Agent}s resolved, implement a specialized version
    # that returns an array of agents from #resolve. This customized
    # implementation would typically be injected to an application-wide
    # {Checkpoint::Authority}, rather than being used directly.
    #
    # For example, a custom resolver might add a group agent for each group that
    # the user is a member of, or IP address-based geographical regions or
    # organizational affiliations.
    class Resolver
      # Resolve an actor to a list of agents it represents.
      #
      # If extending or overriding, you will most likely want to either call
      # super, or use the default conversion directly.
      # @return [[Checkpoint::Agent]] an array of agents for this actor
      # @see Checkpoint::Agent.from
      def resolve(actor)
        [Checkpoint::Agent.from(actor)]
      end
    end
  end
end
