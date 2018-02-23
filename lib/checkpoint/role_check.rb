# frozen_string_literal: true

module Checkpoint
  # A RoleCheck is a self-evaluting rule that captures the user, role, and
  # target, and checks if the authority recognizes the user as having the role.
  class RoleCheck
    attr_reader :user, :role, :target

    def initialize(user, role, target, authority: RejectAll.new)
      @user      = user
      @role      = role.to_sym
      @target    = target
      @authority = authority
    end

    def satisfied?
      authority.permitted?(user, role, target)
    end

    private

    # Dummy authority that rejects everything
    class RejectAll
      def permitted?(*)
        false
      end
    end

    attr_reader :authority
  end
end
