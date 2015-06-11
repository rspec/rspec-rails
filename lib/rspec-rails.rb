require 'rspec/rails/feature_check'

module RSpec
  module Rails
    # private
    module Adapters
      # private
      module NoActionMailer
        # private
        def setup_preview_path(config)
        end
      end

      # private
      module ActionMailerPreviewPath
        # private
        def setup_preview_path(config)
          return unless show_previews?(config.action_mailer)

          # Logic taken from the Action Mailer Railtie
          config.action_mailer.preview_path ||= default_preview_path
        end

        # private
        def show_previews?(options)
          ::Rails.env.development?
        end

        # private
        def default_preview_path
          # Logic taken from the Action Mailer Railtie
          defined?(::Rails.root) ? "#{::Rails.root}/spec/mailers/previews" : nil
        end
      end

      # private
      module ActionMailerShowPreviews
        include ActionMailerPreviewPath

        # private
        def show_previews?(options)
          # Logic taken from the Action Mailer Railtie
          options.show_previews = super if options.show_previews.nil?
          options.show_previews
        end
      end

      # private
      #
      # Checking for `ActionMailer` will not cause the configuration to load.
      # That happens on loading `ActionMailer::Base`, so this check should be
      # safe. The eager loading of the config on `ActionMailer::Base` also
      # prevents us from checking if the `preview_path` and `show_preview`
      # options are defined; so we switch on the Rails version.
      ActionMailerRailtie = if !defined?(::ActionMailer)
                              NoActionMailer
                            elsif ::Rails::VERSION::STRING > '4.2'
                              ActionMailerShowPreviews
                            elsif ::Rails::VERSION::STRING > '4.1'
                              ActionMailerPreviewPath
                            else
                              NoActionMailer
                            end
    end
  end
end

# Namespace for all core RSpec projects.
module RSpec
  # Namespace for rspec-rails code.
  module Rails
    # Railtie to hook into Rails.
    class Railtie < ::Rails::Railtie
      include RSpec::Rails::Adapters::ActionMailerRailtie

      # Rails-3.0.1 requires config.app_generators instead of 3.0.0's config.generators
      generators = config.respond_to?(:app_generators) ? config.app_generators : config.generators
      generators.integration_tool :rspec
      generators.test_framework :rspec

      generators do
        ::Rails::Generators.hidden_namespaces.reject! do |namespace|
          namespace.start_with?("rspec")
        end
      end

      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end

      # This is called after the environment has been loaded but before Rails
      # sets the default for the `preview_path`
      initializer "rspec_rails.action_mailer",
        :before => "action_mailer.set_configs" do |app|
        setup_preview_path app.config
      end
    end
  end
end
