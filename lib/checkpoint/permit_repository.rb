# frozen_string_literal: true

module Checkpoint
  class PermitRepository
    def permits_for(_subjects, _credentials, _resources)
      []
    end
  end
end
