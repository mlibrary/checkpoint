# frozen_string_literal: true

module Checkpoint
  module DB
    # A query object based on agents, credentials, and resources.
    #
    # This query mirrors the essence of the Checkpoint semantics; that is, it
    # finds permits for any supplied agent, for any supplied credential, for
    # any supplied resource.
    #
    # The class is called CartesianSelect because the logical search space is
    # the Cartesian product of the supplied agents X credentials X resources.
    # All permits in that space are selected.
    #
    # This is ultimately implemented as an IN clause for each token type
    # containing all members of that type: one for agent_token, one for
    # credential_token, and one for resource_token.
    #
    # This is a separate class because assembling placeholder variables and
    # binding expressions in the way Sequel expects them is relatively
    # complicated in its own right. It can take single items or arrays and
    # converts them all to their tokens for query purposes.
    class CartesianSelect
      attr_reader :agents, :credentials, :resources, :scope

      def initialize(agents, credentials, resources, scope: Checkpoint::DB::Permit)
        @agents      = tokenize(agents)
        @credentials = tokenize(credentials)
        @resources   = tokenize(resources)
        @scope       = scope
      end

      def query
        scope.where(conditions)
      end

      def all
        exec(:select)
      end

      def first
        exec(:first)
      end

      def delete
        exec(:delete)
      end

      def conditions
        {
          agent_token:      agent_params.placeholders,
          credential_token: credential_params.placeholders,
          resource_token:   resource_params.placeholders,
          zone_id: :$zone_id
        }
      end

      def parameters
        (agent_params.values +
         credential_params.values +
         resource_params.values +
         [[:zone_id, DB::Permit.default_zone]]).to_h
      end

      def agent_params
        Params.new(agents, 'at')
      end

      def credential_params
        Params.new(credentials, 'ct')
      end

      def resource_params
        Params.new(resources, 'rt')
      end

      private

      def exec(mode)
        query.call(mode, parameters)
      end

      def tokenize(collection)
        [collection].flatten.map(&:token)
      end
    end
  end
end
