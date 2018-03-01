# frozen_string_literal: true

require 'ostruct'
require 'logger'

module Checkpoint
  # Module for everything related to the Checkpoint database.
  module DB
    # Any error with the database that Checkpoint itself detects but cannot handle.
    class DatabaseError < StandardError; end

    LOAD_ERROR = <<~MSG
      Error loading Checkpoint database models.
      Verify connection information and that the database is migrated.
    MSG

    CONNECTION_ERROR = 'The Checkpoint database is not initialized. Call initialize! first.'

    class << self
      # Initialize Checkpoint
      #
      # This connects to the database if it has not already happened and
      # requires all of the Checkpoint model classes. It is required to do the
      # connection setup first because of the design decision in Sequel that
      # the schema is examined at the time of extending Sequel::Model.
      def initialize!
        connect! unless connected?
        begin
          model_files.each do |file|
            require_relative file
          end
        rescue Sequel::DatabaseError, NoMethodError => e
          raise DatabaseError, LOAD_ERROR + "\n" + e.message
        end
        db
      end

      # Connect to the Checkpoint database.
      #
      # The default is to use the settings under {.config}, but can be
      # supplied here (and they will be merged into config as a side effect).
      # The keys that will be used from either source are documented here as
      # the options.
      #
      # Only one "mode" will be used; the first of these supplied will take
      # precedence:
      #
      # 1. An already-connected {Sequel::Database} object
      # 2. A connection string
      # 3. A connection options hash
      #
      # While Checkpoint serves as a singleton, this will raise a DatabaseError
      # if already connected. Check `connected?` if you are unsure.
      #
      # @see {Sequel.connect}
      # @param [Hash] config Optional connection config
      # @option config [String] :url A Sequel database URL
      # @option config [Hash]   :opts A set of connection options
      # @option config [Sequel::Database] :db An already-connected database;
      # @return [Sequel::Database] The initialized database connection
      def connect!(config = {})
        raise DatabaseError, "Already connected; refusing to connect to another database" if connected?
        merge_config!(config)
        # We splat here because we might give one or two arguments depending
        # on whether we have a string or not; to add our logger regardless.
        @db = self.config.db || Sequel.connect(*conn_opts)
      end

      # Run any pending migrations.
      # This will connect with the current config if not already conencted.
      def migrate!
        connect! unless connected?
        Sequel.extension :migration
        Sequel::Migrator.run(db, File.join(__dir__, '../../db/migrations'))
      end

      def model_files
        [
          'db/permit'
        ]
      end

      # Merge url, opts, or db settings from a hash into our config
      def merge_config!(config = {})
        self.config.url  = config[:url]  if config.key?(:url)
        self.config.opts = config[:opts] if config.key?(:opts)
        self.config.db   = config[:db]   if config.key?(:db)
      end

      def conn_opts
        log = { logger: Logger.new('db/checkpoint.log') }
        url = config.url
        opts = config.opts || {}
        if url
          [url, log]
        else
          [log.merge(opts)]
        end
      end

      def config
        @config ||= OpenStruct.new(
          url: ENV['CHECKPOINT_DATABASE_URL'] || ENV['DATABASE_URL']
        )
      end

      def connected?
        !@db.nil?
      end

      # The Checkpoint database
      # @return [Sequel::Database] The connected database; be sure to call initialize! first.
      def db
        raise DatabaseError, CONNECTION_ERROR unless connected?
        @db
      end
    end
  end
end
