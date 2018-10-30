# frozen_string_literal: true

# Note: we do not require db/permit because Sequel requires the connection
# to be set up before defining the model classes. The arrangment here
# assumes that DB.initialize! will have been called if the default model
# is to be used. In tests, that is done by spec/sequel_helper.rb. In an
# application, there should be an initializer that reads whatever appropriate
# configuration and does the initialization.

require 'checkpoint/db'

module Checkpoint
  # The repository of permits -- a simple wrapper for the Sequel Datastore / permits table.
  class Permits
    def initialize(permits: Checkpoint::DB::Permit)
      @permits = permits
    end

    def for(agents, credentials, resources)
      where(agents, credentials, resources).all
    end

    def any?(agents, credentials, resources)
      where(agents, credentials, resources).first != nil
    end

    # Grant a single permit.
    # @return [Permit] the saved Permit; nil if the save fails
    def permit!(agent, credential, resource)
      permits.from(agent, credential, resource).save
    end

    # Delete matching permits.
    #
    # Take care to note that this follows the same matching semantics as
    # {.for}. There is no expansion done here, but anything that matches what
    # is supplied will be deleted. Of particular note is the default wildcard
    # behavior of {Checkpoint::Resource::Resolver}: if a specific resource has
    # been expanded by the resolver, and the array of the resource, a type
    # wildcard, and the any-resource wildcard (as used for inherited matching)
    # is supplied, the results may be surprising where there are permits at
    # specific and general levels.
    #
    # In general, the parameters should not have been expanded. If the intent
    # is to revoke a general permit, the general details should be supplied,
    # and likewise for the specific case.
    #
    # Applications should interact with the {Checkpoint::Authority}, which
    # exposes a more application-oriented interface. This repository should be
    # considered internal to Checkpoint.
    #
    # @param agents [Agent|Array] the agent or agents to match for deletion
    # @param credentials [Credential|Array] the credential or credentials to match for deletion
    # @param resources [Resource|Array] the resource or resources to match for deletion
    # @return [Integer] the number of Permits deleted
    def revoke!(agents, credentials, resources)
      where(agents, credentials, resources).delete
    end

    private

    def where(agents, credentials, resources)
      CartesianSelect.new(agents, credentials, resources, scope: permits)
    end

    attr_reader :permits

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

    # A helper for building placeholder variable names from items in a list and
    # providing a corresponding hash of values. A prefix with some mnemonic
    # corresponding to the column is recommended. For example, if the column is
    # `agent_token`, using the prefix `at` will yield `$at_0`, `$at_1`, etc. for
    # an IN clause.
    class Params
      attr_reader :items, :prefix

      def initialize(items, prefix)
        @items  = [items].flatten
        @prefix = prefix
      end

      def placeholders
        0.upto(items.size - 1).map do |i|
          :"$#{prefix}_#{i}"
        end
      end

      def values
        items.map.with_index do |item, i|
          value = if item.respond_to?(:sql_value)
                    item.sql_value
                  else
                    item.to_s
                  end
          [:"#{prefix}_#{i}", value]
        end
      end
    end
  end
end
