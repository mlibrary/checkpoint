# frozen_string_literal: true

require "checkpoint/version"

require 'sequel'
require 'mysql2'
require 'ettin'
require 'pry' rescue LoadError

require 'checkpoint/permission_mapper'
require 'checkpoint/user_directory'

require 'checkpoint/agent_resolver'
require 'checkpoint/credential_resolver'
require 'checkpoint/resource_resolver'

module Checkpoint
  # Your code goes here...
end
