# frozen_string_literal: true

require 'checkpoint/authority'

module Checkpoint
  # A RoleCheck is a self-evaluting rule that captures the user, role, and
  # target, and checks if the authority recognizes the user as having the role.
  class RoleCheck
    attr_reader :user, :role, :target

    def initialize(user, role, target, authority: Authority::RejectAll.new)
      @user      = user
      @role      = role.to_sym
      @target    = target
      @authority = authority
    end

    def satisfied?
      authority.permits?(user, role, target)
    end

    private

    attr_reader :authority
  end
end
