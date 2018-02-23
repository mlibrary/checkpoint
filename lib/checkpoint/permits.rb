# frozen_string_literal: true

module Checkpoint
  # The repository of permits -- a simple wrapper for the Sequel Datastore / permits table.
  class Permits
    def for(_subjects, _credentials, _resources)
      []
    end
  end
end
