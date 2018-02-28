# frozen_string_literal: true

require 'bundler/setup'
require 'checkpoint'
require 'sequel'

namespace :checkpoint do
  desc "Migrate the Checkpoint database to the latest version"
  task :migrate do
    if defined?(Checkpoint::Railtie)
      # Set up the callback to connect and migrate before any initializers run
      Checkpoint::Railtie.before_initializers do
        Checkpoint::DB.migrate!
      end

      # Load the 'environment', which does the full Rails initialization and
      # will fire the callback at the right time.
      Rake::Task['environment'].invoke
    else
      Checkpoint::DB.migrate!
      # raise 'Not running under rails and no CHECKPOINT_DATABASE_URL'
    end
  end
end
