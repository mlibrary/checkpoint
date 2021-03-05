# frozen_string_literal: true

require "checkpoint/credential/role"
require "checkpoint/credential/permission"

class FakeEditor < Checkpoint::Credential::Role
  def initialize
    super "editor"
  end
end

class FakeRead < Checkpoint::Credential::Permission
  def initialize
    super "read"
  end

  def granted_by
    [self, FakeEditor.new]
  end
end
