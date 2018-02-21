# frozen_string_literal: true

module Checkpoint
  class ResourceResolver
    def resolve(target)
      [entity_token(target), type_token(target)]
    end

    private

    def entity_token(target)
      "#{target.entity_type}:#{target.id}"
    end

    def type_token(target)
      "type:#{target.entity_type}"
    end
  end
end
