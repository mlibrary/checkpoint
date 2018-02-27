# frozen_string_literal: true

module Checkpoint
  class Credential
    class Role < Credential
      TYPE = 'role'

      def type
        TYPE
      end
    end
  end
end
