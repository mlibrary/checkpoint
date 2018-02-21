# frozen_string_literal: true

require 'checkpoint/user_directory'

module Checkpoint
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
