# frozen_string_literal: true

module Checkpoint
  # A UserDirectory takes a concrete user/actor and resolves it into all of the
  # authentication attributes, such as username and group memberships. This
  # resolution is considered in the context of a usage session, so attributes
  # such as IP address-based geographic region or institutional affiliation are
  # appropriate here.
  class UserDirectory
    def attributes_for(_user)
      {}
    end
  end
end
