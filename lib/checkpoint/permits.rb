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
      where(agents, credentials, resources).to_a
    end

    def any?(agents, credentials, resources)
      where(agents, credentials, resources).any?
    end

    private

    def where(agents, credentials, resources)
      permits
        .where(agent_token: tokenize(agents))
        .where(credential_token: tokenize(credentials))
        .where(resource_token: tokenize(resources))
        .where(zone_id: permits.default_zone)
    end

    def tokenize(collection)
      [collection].flatten.compact.map(&:token)
    end

    attr_reader :permits
  end
end
