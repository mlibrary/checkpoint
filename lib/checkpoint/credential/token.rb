# frozen_string_literal: true

require 'checkpoint/credential/resolver'
require 'checkpoint/permission_mapper'

module Checkpoint
  # A Credential is the permission to take a particular action, or any
  # instrument that can represent multiple permissions, such as a role or
  # license.
  #
  # Credentials are abstract; that is, they are not attached to a particular
  # actor or resource to be acted upon. A credential can be granted to an
  # {Agent}, optionally applying to a particular resource, by way of a Permit.
  # In other words, a credential can be likened to a class, while a permit can
  # be likened to an instance of that class, bound to a given agent and
  # possibly bound to a {Resource}.
  class Credential
    attr_reader :type, :id

    # Create a new Credential representing a permission or instrument that
    # represents multiple permissions.
    #
    # @param type [String] the application-determined type of this credential.
    #   For example, this might be 'permission' or 'role'.
    #
    # @param id [String] the application-resolvable identifier for this
    #   credential. For example, this might be an action to be taken or the ID
    #   of a role.
    def initialize(type, id)
      @type = type.to_s
      @id = id.to_s
    end

    # @return [String] a token suitable for granting or matching this credential
    def token
      "#{type}:#{id}"
    end

    # @return [String] a URI for this credential, including its type and id
    def uri
      "credential://#{type}/#{id}"
    end

    # @return [String] this credential's token
    # @see #token
    def to_s
      token
    end

    # Compare with another Credential for equality. Consider them to represent
    # the same credential if `other` is a credential, has the same type, and same id.
    def eql?(other)
      other.is_a?(Credential) && type == other.type && id == other.id
    end

    alias == eql?
  end
end
