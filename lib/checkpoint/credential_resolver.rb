# frozen_string_literal: true

require 'checkpoint/permission_mapper'

module Checkpoint
  class CredentialResolver
    def initialize(permission_mapper: PermissionMapper.new)
      @permission_mapper = permission_mapper
    end

    def resolve(action)
      permissions_for(action) + roles_granting(action)
    end

    private

    def permissions_for(action)
      perms = permission_mapper.permissions_for(action)
      perms.map { |p| "permission:#{p}" }
    end

    def roles_granting(action)
      roles = permission_mapper.roles_granting(action)
      roles.map { |r| "role:#{r}" }
    end

    attr_reader :permission_mapper
  end
end
