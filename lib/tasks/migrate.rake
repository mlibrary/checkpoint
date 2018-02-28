# frozen_string_literal: true

require 'bundler/setup'
require 'checkpoint'
require 'logger'
require 'sequel'

Sequel.extension :migration

namespace :checkpoint do
  desc "Migrate the Checkpoint database to the latest version"
  task :migrate do
    opts = { logger: Logger.new('db/checkpoint.log') }
    url = ENV['CHECKPOINT_DATABASE_URL'] || ENV['DATABASE_URL']

    if url
      db = Sequel.connect(url, opts)
    elsif defined?(Checkpoint::Railtie)
      Rake::Task['environment'].invoke
      conn_opts = Checkpoint::Railtie.conn_opts
      db = Sequel.connect(conn_opts.merge(opts))
    else
      raise 'Not running under rails and no CHECKPOINT_DATABASE_URL'
    end

    Sequel::Migrator.run(db, File.join(__dir__, '../../db/migrations'))
  end
end
