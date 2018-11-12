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

    # Find grants of the given credentials on the given resources.
    #
    # This is useful for finding who should have particular access. Note that
    # this low-level interface returns the full grants, rather than a unique
    # set of agents.
    #
    # @return [Array<Permit>] the set of grants of any of the credentials on
    #   any of the resources
    def who(credentials, resources)
      DB::Query::CR.new(credentials, resources, **scope).all
    end

    # Find grants to the given agents on the given resources.
    #
    # This is useful for finding what actions may be taken on particular items.
    # Note that this low-level interface returns the full grants, rather than a
    # unique set of credentials.
    #
    # @return [Array<Permit>] the set of grants to any of the agents on any of
    #   the resources
    def what(agents, resources)
      DB::Query::AR.new(agents, resources, **scope).all
    end

    # Find grants to the given agents of the given credentials.
    #
    # This is useful for finding which resources may acted upon. Note that this
    # low-level interface returns the full grants, rather than a unique set of
    # resources.
    #
    # @return [Array<Permit>] the set of grants of any of the credentials to
    #   any of the agents
    def which(agents, credentials)
      DB::Query::AC.new(agents, credentials, **scope).all
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

    def scope
      { scope: permits }
    end

    def where(agents, credentials, resources)
      DB::Query::ACR.new(agents, credentials, resources, **scope)
    end

    attr_reader :permits
  end
end
