# frozen_string_literal: true

module Checkpoint
  class Railtie < Rails::Railtie
    railtie_name :checkpoint

    initializer "checkpoint.setup_database", after: :load_config_initializers do |app|
      # Probably want to initialize! here if it hasn't been called yet.
    end

    def self.conn_opts
      conn_opts = ActiveRecord::Base.connection.instance_variable_get(:@config)
      conn_opts.delete(:flags)
      conn_opts
    end

    rake_tasks do
      load "tasks/migrate.rake"
    end
  end
end
