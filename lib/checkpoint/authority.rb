# frozen_string_literal: true

require 'checkpoint/agent/resolver'
require 'checkpoint/credential/resolver'
require 'checkpoint/resource/resolver'
require 'checkpoint/permits'

module Checkpoint
  # An Authority is the central point of contact for authorization questions in
  # Checkpoint. It checks whether there are permits that would allow a given
  # action to be taken.
  class Authority
    def initialize(
      agent_resolver: Agent::Resolver.new,
      credential_resolver: Credential::Resolver.new,
      resource_resolver: Resource::Resolver.new,
      permits: Permits.new)

      @agent_resolver      = agent_resolver
      @credential_resolver = credential_resolver
      @resource_resolver   = resource_resolver
      @permits             = permits
    end

    # Check whether there are any matching permits that would allow this actor
    # to take the action on the target entity.
    #
    # The parameters are generally intended to be the most convenient forms for
    # the application. For example, user and resource model objects would be
    # typical in a Rails application, for the actor and entity, respectively.
    # Using a symbol for a named action is typical.
    #
    # Each of these will be converted and expanded by the corresponding
    # resolver to sets of {Agent}s, {Credential}s, and {Resource}s. In the case
    # where you already have an Agent, Credential, or Resource, it can be
    # passed; the expectation is that those types have an identity conversion.
    #
    # @param actor [Object|Agent] The person/account taking the action.
    # @param action [Symbol|String|Credential] The action to authorize or
    #   Credential to check for.
    # @param entity [Object|Resource] The entity/resource to be acted upon.
    def permits?(actor, action, entity)
      # Conceptually equivalent to:
      #   can?(current_user, :edit, @listing)

      #  user   => agent tokens
      #  action => credential tokens
      #  target => resource tokens

      # Permit.where(agent: agents, credential: credentials, resource: resources)
      # SELECT * FROM permits
      # WHERE agent IN('user:gkostin', 'account-type:umich', 'affiliation:lib-staff')
      # AND credential IN('permission:edit', 'role:editor')
      # AND resource IN('listing:17', 'type:listing')

      #  agent_type, agent_id    | cred_type, cred_id | resource_type, resource_id
      #  ------------------------------------------------------------------------
      #  'user:gkostin'          | 'permission:edit'  | 'listing:17'
      #  'account-type:umich'    | 'role:editor'      | 'type:listing'
      #  'affiliation:lib-staff' |                    | 'listing:*'

      #        ^^^                       ^^^^              ^^^^
      #   if current_user has at least one row in each of of these columns,
      #   they have been "granted permission"
      permits.for(
        agent_resolver.expand(actor),
        credential_resolver.expand(action),
        resource_resolver.expand(entity)
      ).any?
    end

    # Find agents who have grants to take an action on an entity.
    #
    # The action and entity are expanded for matching more general grants.
    #
    # @return [Array<Agent::Token>] The distinct set of tokens for agents permitted to
    #   take the given action on the given entity
    def who(action, entity)
      credentials = credential_resolver.expand(action)
      resources = resource_resolver.expand(entity)

      permits.who(credentials, resources).map do |permit|
        Agent::Token.new(permit.agent_type, permit.agent_id)
      end.uniq
    end

    # Grant a single credential to a specific actor on an entity.
    #
    # The parameters are converted to Agent, Credential, and Resource types,
    # but not expanded. This allows very specific grants to be made. The
    # default conversion of a symbol or string as the action is to a
    # {Credential::Permission} of the same name.
    #
    # If you want to use more general grants (for example, for an account type
    # rather than for a given user), you should pass a more general Agent or an
    # object that will be converted to one. Another example would be using a
    # wildcard Resource as the entity to grant the credential for all objects
    # of some given type.
    #
    # @param actor [Object|Agent] The actor to whom the grant should be made.
    # @param action [Symbol|String|Credential] The action or Credential to grant.
    # @param entity [Object|Resource] The entity or Resource to which the
    #   grant will apply.
    # @return [Boolean] True if the grant was made; false if it failed.
    def permit!(actor, action, entity)
      permit = permits.permit!(
        agent_resolver.convert(actor),
        credential_resolver.convert(action),
        resource_resolver.convert(entity)
      )

      !permit.nil?
    end

    # Revoke a credential from a specific actor on an entity.
    #
    # Like {#permit!}, the parameters are converted to Agent, Credential, and
    # Resource types, but not expanded. This means that specific grants can be
    # revoked without revoking more general ones. For example, if a user was
    # granted read permission on an object, and then granted the same credential
    # on all objects of that type, the more specific grant could be revoked
    # individually.
    #
    # @param actor [Object|Agent] The actor from whom the grant should be revoked.
    # @param action [Symbol|String|Credential] The action or Credential to revoke.
    # @param entity [Object|Resource] The entity or Resource upon which the
    # @return [Boolean] True if any permits were revoked; false if none were revoked.
    def revoke!(actor, action, entity)
      revoked = permits.revoke!(
        agent_resolver.convert(actor),
        credential_resolver.convert(action),
        resource_resolver.convert(entity)
      )

      revoked.positive?
    end

    # Dummy authority that rejects everything
    class RejectAll
      def permits?(*)
        false
      end
    end

    private

    attr_reader :agent_resolver, :credential_resolver, :resource_resolver, :permits
  end
end
