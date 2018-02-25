# frozen_string_literal: true

require 'checkpoint/permission_mapper'

module Checkpoint
  # A CredentialResolver takes a concrete action and resolves it into
  # any {Credential}s that would permit the action. It uses a
  # {PermissionMapper} to accommodate application extensions to this resolution.
  class CredentialResolver
    def initialize(permission_mapper: PermissionMapper.new)
      @permission_mapper = permission_mapper
    end

    def resolve(action)
      return [action] if action.is_a?(Credential)
      permissions_for(action) + roles_granting(action)
    end

    private

    def permissions_for(action)
      perms = permission_mapper.permissions_for(action)
      perms.map { |perm| Credential.new('permission', perm) }
    end

    def roles_granting(action)
      roles = permission_mapper.roles_granting(action)
      roles.map { |role| Credential.new('role', role) }
    end

    attr_reader :permission_mapper
  end
end
