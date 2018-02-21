# frozen_string_literal: true

module Checkpoint
  class PermissionMapper
    def permissions_for(action)
      [action.to_sym]
    end

    def roles_granting(action)
      []
    end
  end
end
