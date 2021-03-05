# frozen_string_literal: true

raise "MigrationCheck is intended only to be required one time" if defined?(MigrationCheck)

# This is a fake model to require in the one DB test for the migration check.
# See spec/checkpoint/db_spec.rb, under #initialize!
class MigrationCheck < Sequel::Model
end
