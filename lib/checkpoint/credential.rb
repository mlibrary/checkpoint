# frozen_string_literal: true

require 'checkpoint/credential/resolver'
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
    extend Forwardable
    def_delegators :@token, :type, :id, :token
    def initialize(type,id)
      @token = Token.new(type, id)
    end
    def _token
      @token
    end
    def eql?(other)
      _token.eql?(other._token)
    end
    def ==(other)
      _token == other._token
    end
  end
end
