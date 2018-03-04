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
      where(agents, credentials, resources).select
    end

    def any?(agents, credentials, resources)
      where(agents, credentials, resources).first != nil
    end

    private

    def where(agents, credentials, resources)
      Query.new(agents, credentials, resources, scope: permits)
    end

    attr_reader :permits

    # A query object based on agents, credentials, and resources.
    #
    # This is a helper to capture a set of agents, credentials, and resources,
    # and manage assembly of placeholder variables and binding expressions in
    # the way Sequel expects them. It can take single items or arrays and
    # converts them all to their tokens for query purposes.
    class Query
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

      def select
        exec(:select)
      end

      def first
        exec(:first)
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
