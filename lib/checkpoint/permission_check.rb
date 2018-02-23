# frozen_string_literal: true

require 'checkpoint/authority'

module Checkpoint
  # A PermissionCheck is a self-evaluting rule that captures the user, action,
  # and target, and checks if the authority permits the action.
  class PermissionCheck
    attr_reader :user, :action, :target

    def initialize(user, action, target, authority: Authority::RejectAll.new)
      @user      = user
      @action    = action.to_sym
      @target    = target
      @authority = authority
    end

    def satisfied?
      authority.permits?(user, action, target)
    end

    private

    attr_reader :authority
  end
end
