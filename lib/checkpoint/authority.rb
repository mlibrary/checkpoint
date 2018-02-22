# frozen_string_literal: true

require 'checkpoint/agent_resolver'
require 'checkpoint/credential_resolver'
require 'checkpoint/resource_resolver'
require 'checkpoint/permit_repository'

module Checkpoint
  # An Authority is the central point of contact for authorization questions in
  # Checkpoint. It checks whether there are permits that would allow a given
  # action to be taken.
  class Authority
    attr_reader :user, :action, :target, :grants
    attr_writer :agent_resolver, :credential_resolver, :resource_resolver, :repository

    def initialize(user, action, target)
      @user = user
      @action = action
      @target = target
    end

    def any?
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

      permits.any?
    end

    private

    def permits
      repository.permits_for(agents, credentials, resources)
    end

    def agents
      agent_resolver.resolve(user)
    end

    def credentials
      credential_resolver.resolve(action)
    end

    def resources
      resource_resolver.resolve(target)
    end

    def agent_resolver
      @agent_resolver ||= AgentResolver.new
    end

    def credential_resolver
      @credential_resolver ||= CredentialResolver.new
    end

    def resource_resolver
      @resource_resolver ||= ResourceResolver.new
    end

    def repository
      @repository ||= PermitRepository.new
    end
  end
end
