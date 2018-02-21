# frozen_string_literal: true

# This is a dumb placeholder for what will likely be a thin layer
# over ActiveRecord -- or we might inject an AR model directly.
module Checkpoint
  class GrantRepository
    def grants_for(_, _, _)
      []
    end
  end
end
