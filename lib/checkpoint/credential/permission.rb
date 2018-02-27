# frozen_string_literal: true

module Checkpoint
  class Credential
    class Permission < Credential
      TYPE = 'permission'

      def type
        TYPE
      end
    end
  end
end
