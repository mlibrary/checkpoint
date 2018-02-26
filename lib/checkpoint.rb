# frozen_string_literal: true

require "checkpoint/version"

require 'sequel'
require 'mysql2'
require 'ettin'

# All of the Checkpoint components are contained within this top-level module.
module Checkpoint
  # Nothing here for now...
end

require 'checkpoint/agent/token'
require 'checkpoint/credential/token'
require 'checkpoint/resource/token'
require 'checkpoint/authority'
require 'checkpoint/query'
