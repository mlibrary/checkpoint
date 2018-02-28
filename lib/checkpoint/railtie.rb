# frozen_string_literal: true

module Checkpoint
  # Railtie to hook Checkpoint into Rails applications.
  #
  # This does three things at present:
  #
  #   1. Loads our rake tasks, so you can run checkpoint:migrate from the app.
  #   2. Pulls the Rails database information off of the ActiveRecord
  #      connection and puts it on Checkpoint::DB.config before any application
  #      initializers are run.
  #   3. Sets up the Checkpoint database connection after application
  #      initializers have run, if it has not already been done.
  class Railtie < Rails::Railtie
    railtie_name :checkpoint

    class << self
      # Register a callback to run before anything in 'config/initializers' runs.
      # The block will get a reference to Checkpoint::DB.config as its only parameter.
      def before_initializers(&block)
        before_blocks << block
      end

      # Register a callback to run after anything in 'config/initializers' runs.
      # The block will get a reference to Checkpoint::DB.config as its only parameter.
      # Checkpoint::DB.initialize! will not have been automatically called at this
      # point, so this is an opportunity to do so if an initializer has not.
      def after_initializers(&block)
        after_blocks << block
      end

      # Register a callback to run when Checkpoint is ready and fully initialized.
      # This will happen once in production, and on each request in development.
      # If you need to do something once in development, you can choose between
      # keeping a flag or using the after_initializers.
      def when_checkpoint_is_ready(&block)
        ready_blocks << block
      end

      def before_blocks
        @before ||= []
      end

      def after_blocks
        @after ||= []
      end

      def ready_blocks
        @ready ||= []
      end
    end

    # This runs before anything in 'config/initializers' runs.
    initializer "checkpoint.before_initializers", before: :load_config_initializers do
      config = Checkpoint::DB.config
      unless config.url
        opts = ActiveRecord::Base.connection.instance_variable_get(:@config).dup
        opts.delete(:flags)
        config[:opts] = opts
      end

      Railtie.before_blocks.each do |block|
        block.call(config.to_h)
      end
    end

    # This runs after everything in 'config/initializers' runs.
    initializer "checkpoint.after_initializers", after: :load_config_initializers do
      config = Checkpoint::DB.config
      Railtie.after_blocks.each do |block|
        block.call(config.to_h)
      end
    end

    # This runs before any block registered under a `config.to_prepare`, which
    # could be in plugins or initializers that want to use a fully configured
    # Checkpoint instance. The `to_prepare` hook is run once at the start of a
    # production instance and for every request in development (unless caching
    # is turned on so there is no reloading).
    initializer "checkpoint.ready", before: :add_to_prepare_blocks do
      Checkpoint::DB.initialize!

      Railtie.ready_blocks.each do |block|
        block.call(Checkpoint::DB.db)
      end
    end

    rake_tasks do
      load "tasks/migrate.rake"
    end
  end
end
