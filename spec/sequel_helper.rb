# frozen_string_literal: true

# Require this helper in tests that need to use the database.
# Also remember to tag the example groups with `DB: true` so each one is
# wrapped in a transaction that rolls back to handle cleanup.

require_relative 'spec_helper'
require 'checkpoint/db'

url = ENV.fetch('DATABASE_URL', nil)
if url
  Checkpoint::DB.connect!(url: url)
else
  # Set up an in-memory SQLite database and migrate it all the way up
  db = Sequel.sqlite
  Checkpoint::DB.connect!(db: db)
  Checkpoint::DB.migrate!
end
Checkpoint::DB.initialize!

RSpec.configure do |config|
  config.around(:each, DB: true) do |example|
    Checkpoint::DB.db.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end
