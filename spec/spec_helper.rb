# frozen_string_literal: true

require "bundler/setup"
if ENV['COVERAGE'] || ENV['TRAVIS']
  require "coveralls"
  Coveralls.wear! do
    add_filter 'spec/sequel_helper.rb'
  end
end

require "checkpoint"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
