# frozen_string_literal: true

module Checkpoint
  module DB
    # Sequel model for permits
    class Permit < Sequel::Model
      # Instantiate a Permit from the constituent domain objects (agent,
      # resource, credential).
      def self.from(agent, credential, resource, zone: 'system')
        new(
          agent_type: agent.type,           agent_id: agent.id,           agent_token: agent.token,
          credential_type: credential.type, credential_id: credential.id, credential_token: credential.token,
          resource_type: resource.type,     resource_id: resource.id,     resource_token: resource.token,
          zone_id: zone
        )
      end

      # The default/system zone
      def self.default_zone
        '(all)'
      end
    end
  end
end
