# frozen_string_literal: true

require 'checkpoint/agent_resolver'
require 'checkpoint/credential_resolver'
require 'checkpoint/resource_resolver'
require 'checkpoint/permits'

module Checkpoint
  # An Authority is the central point of contact for authorization questions in
  # Checkpoint. It checks whether there are permits that would allow a given
  # action to be taken.
  class Authority
    def initialize(
      agent_resolver: AgentResolver.new,
      credential_resolver: CredentialResolver.new,
      resource_resolver: ResourceResolver.new,
      permits: Permits.new)

      @agent_resolver      = agent_resolver
      @credential_resolver = credential_resolver
      @resource_resolver   = resource_resolver
      @permits             = permits
    end

    def permits?(agent, credential, resource)
      # Conceptually equivalent to:
      #   can?(agent, action, target)
      #   can?(current_user, 'edit', @listing)

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
        agent_resolver.resolve(agent),
        credential_resolver.resolve(credential),
        resource_resolver.resolve(resource)
      ).any?
    end

    private

    attr_reader :agent_resolver, :credential_resolver, :resource_resolver, :permits
  end
end
