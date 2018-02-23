# frozen_string_literal: true

module Checkpoint
  # A PermissionCheck is a self-evaluting rule that captures the user, action,
  # and target, and checks if the authority permits the action.
  class PermissionCheck
    attr_reader :user, :action, :target

    def initialize(user, action, target, authority: RejectAll.new)
      @user      = user
      @action    = action.to_sym
      @target    = target
      @authority = authority
    end

    def satisfied?
      authority.permits?(user, action, target)
    end

    private

    # Dummy authority that rejects everything
    class RejectAll
      def permits?(*)
        false
      end
    end

    attr_reader :authority
  end
end
