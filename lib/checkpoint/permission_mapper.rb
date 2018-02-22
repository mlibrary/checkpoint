# frozen_string_literal: true

module Checkpoint
  # A PermissionMapper translates an action into a set of permissions and roles
  # that would allow it. Commonly, the actions and permissions will share names
  # for convenience and consistency, but this is not a requirement.
  #
  # For example, it may make sense in an application that one permission
  # implies another, so an action may have multiple permissions that would
  # allow it. In another application, it may be more convenient and
  # understandable for users to have separate roles encapsulate that concept
  # (such as an editor role having all of the permissions of a reader role and
  # more).
  #
  # As a separate example, it may be more appropriate to implement permission
  # inheritance directly in policy code (as by delegating to another check or
  # policy), relying on the matching action and permission names with no roles
  # resolved, as given by the default PermissionMapper. Checkpoint does not
  # take an absolute position on the best pattern for a given application.
  class PermissionMapper
    def permissions_for(action)
      [action.to_sym]
    end

    def roles_granting(_action)
      []
    end
  end
end
