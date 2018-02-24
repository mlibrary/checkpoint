# frozen_string_literal: true

require 'checkpoint/user_directory'

module Checkpoint
  # An AgentResolver takes a concrete user object and resolves it into the set
  # of {Agent}s that the user has authenticated as. This has the effect of
  # allowing a Permit to any of those agents to take effect when authorizing an
  # action by this user.

  # For example, a known user will be resolved into an {Agent} with the user
  # type and their username as the ID, at the very least. The set of {Agent}s
  # resolved can be extended by implementing a {UserDirectory} for application
  # needs such as group membership, IP address-based identification and so on.
  class AgentResolver
    def initialize(directory: UserDirectory.new)
      @directory = directory
    end

    def resolve(user)
      [user_token(user)] + additional_tokens(user)
    end

    private

    attr_reader :directory

    def user_token(user)
      "user:#{user.username}"
    end

    def additional_tokens(user)
      attributes = directory.attributes_for(user)
      account_tokens(attributes) + affiliation_tokens(attributes)
    end

    def account_tokens(attributes)
      type = attributes[:account_type] || 'guest'
      ["account-type:#{type}"]
    end

    def affiliation_tokens(attributes)
      affiliations = attributes[:affiliations] || []
      affiliations.map { |a| "affiliation:#{a}" }
    end
  end
end
