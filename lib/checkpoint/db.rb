# frozen_string_literal: true

module Checkpoint
  # Module for everything related to the Checkpoint database.
  module DB
    LOAD_ERROR = <<~MSG
      Error loading Checkpoint database models.
      Verify connection information and that the database is migrated.
    MSG

    CONNECTION_ERROR = 'The Checkpoint database is not initialized. Call initialize! first.'

    class << self
      # Connect to the Checkpoint database.
      #
      # This initializes the database and requires all of the Checkpoint model
      # classes. It is required to do the connection setup first because of the
      # design decision in Sequel that the schema is examined at the time of
      # extending Sequel::Model.
      #
      # @param url [String] A Sequel database URL
      # @param db [Sequel::Database] An already-connected database;
      #   if supplied, `url` will be ignored
      # @return [Sequel::Database] The initialized database connection
      def initialize!(url: nil, db: nil)
        @db = db || Sequel.connect(url)
        begin
          require_relative 'db/permit'
        rescue Sequel::DatabaseError => e
          raise StandardError, LOAD_ERROR + "\n" + e.message
        end
        @db
      end

      # The Checkpoint database
      # @return [Sequel::Database] The connected database; be sure to call initialize! first.
      def db
        raise StandardError, CONNECTION_ERROR if @db.nil?
        @db
      end
    end
  end
end
