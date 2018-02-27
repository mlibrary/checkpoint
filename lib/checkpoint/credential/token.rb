# frozen_string_literal: true

module Checkpoint
  class Credential
    class Token
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
        other.is_a?(Token) && type == other.type && id == other.id
      end

      alias == eql?
    end
  end
end
