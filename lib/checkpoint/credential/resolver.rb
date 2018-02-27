# frozen_string_literal: true

require 'checkpoint/permission_mapper'

module Checkpoint
  class Credential
    # A Credential Resolver takes a concrete action name and resolves it into any
    # {Credential}s that would permit the action.
    #
    # Checkpoint makes no particular demand on the credential model for an
    # application, but offers a useful default implementation supporting
    # permissions and roles. There are no default rules in Checkpoint as to which
    # permissions or roles exist and, therefore, it has no default mapping of
    # roles to permissions.
    #
    # This default resolver can be advised about an application model using roles
    # and permissions customized by using one or both of two extension points:
    #
    #   1. Supplying a {PermissionMapper} gives a way to map action names to any
    #      "larger" permissions (e.g., "manage" being a shorthand for all CRUD
    #      operations on a Resource type) or roles that would grant a given
    #      permission. This affords a rather straightforward mapping of strings
    #      or symbols, short of building customized Credential types.
    #
    #   2. Implementing your own {Credential} types gives a way to model an
    #      application's credentials in an object-oriented way. If the resolver
    #      receives a {Credential} (rather than a string or symbol), it will call
    #      `#granted_by` on it to expand it. The Credential should be sure to
    #      include itself in the array it returns unless it is virtual and should
    #      never be considered as granted directly.
    #
    class Resolver
      def initialize(permission_mapper: PermissionMapper.new)
        @permission_mapper = permission_mapper
      end

      # Resolve an action into all {Credential}s that would permit it.
      #
      # When supplied a string or symbol, we call `permissions_for` and
      # `roles_granting` on the {PermissionMapper} creating a {Permission} or
      # {Role} for every result, returning them all in an array.
      #
      # When supplied a Credential, we call `#granted_by` on it and bypass the
      # PermissionMapper. More precisely, we only check that the object responds to
      # `#granted_by?`, but it would generally be a Credential subclass. The
      # Credential should return an array, but we ensure the return type by
      # wrapping and flattening.
      #
      # Note that the parameter name to `resolve` is `action`. This isn't a perfect
      # name, but credentials are polymorphic such a way that there really is no
      # better application-side term (cf. actor -> Agent, entity -> Resource). It
      # would be something like `action_or_role`, `permission_or_role`, or a generic
      # `credential`. Part of the naming intent here was to distinguish from the
      # action and the ability to perform it. This inheritance relationship
      # permissions and roles are both credential types is a distinguishing feature
      # of Checkpoint, as opposed to models that treat permissions and roles as
      # distinct concepts that must be granted in very different ways. A better
      # name for this parameter may emerge over time, but it seems unlikely. The
      # name `action` was selected because the most common and appropriate concrete
      # thing to look for is a permission to take a named application action.
      #
      # @param action [String|Symbol|Credential] the action name or Credential
      #   to expand into any Credential that would grant it.
      def resolve(action)
        if action.respond_to?(:granted_by)
          [action.granted_by].flatten
        else
          permissions_for(action) + roles_granting(action)
        end
      end

      private

      def permissions_for(action)
        perms = permission_mapper.permissions_for(action)
        perms.map { |perm| Credential::Permission.new(perm) }
      end

      def roles_granting(action)
        roles = permission_mapper.roles_granting(action)
        roles.map { |role| Credential::Role.new(role) }
      end

      attr_reader :permission_mapper
    end
  end
end
