# frozen_string_literal: true

require 'checkpoint/credential/resolver'
require 'checkpoint/credential/role'
require 'checkpoint/credential/permission'
require 'checkpoint/credential/token'
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
    attr_reader :type, :name

    # Create a new generic Credential. This should generally not be called,
    # preferring to use a factory or instantiate a {Permission}, {Role}, or
    # custom Credential class.
    #
    # This class assigns the type 'credential', while most often, applications
    # will want a {Permission}.
    #
    # @param name [String|Symbol] the name of this credential
    def initialize(name)
      @name = name.to_s
      @type = 'credential'
    end

    # Return the list of Credentials that would grant this one.
    #
    # This is an extension mechanism for application authors needing to
    # implement hierarchical or virtual credentials and wanting to do so in
    # an object-oriented way. The default implementation is to simply return
    # the credential itself in an array but, for example, an a custom
    # permission type could provide for aliasing by including itself and
    # another instance for the synonym. Another example is modeling permissions
    # granted by particular roles; this might be static, as defined in the
    # source files, or dynamic, as impacted by configuration or runtime data.
    #
    # As an alternative, these rules could be implemented under a
    # {PermissionMapper} in an application that prefers to model its credentials
    # as strings or symbols, rather than more specialized objects.
    #
    # @see Checkpoint::PermissionMapper
    # @return [Array<Credential>] the expanded list of credentials that would
    #   grant this one
    def granted_by
      [self]
    end

    # @return [Token] a token for this credential
    def token
      @token ||= Token.new(type, name)
    end

    # Compare two Credentials.
    # @param other [Credential] the Credential to compare
    # @return [Boolean] true if `other` is a Credential and its type and name
    #   are both eql? to {#type} and {#name}
    def eql?(other)
      type.eql?(other.type) && name.eql?(other.name)
    end

    alias == eql?
  end
end
