require 'rspec/rails/feature_check'

# Namespace for all core RSpec projects.
module RSpec
  # Namespace for rspec-rails code.
  module Rails
    # Railtie to hook into Rails.
    class Railtie < ::Rails::Railtie
      # Rails-3.0.1 requires config.app_generators instead of 3.0.0's config.generators
      generators = config.respond_to?(:app_generators) ? config.app_generators : config.generators
      generators.integration_tool :rspec
      generators.test_framework :rspec

      generators do
        ::Rails::Generators.hidden_namespaces.reject! { |namespace| namespace.start_with?("rspec") }
      end

      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end

      # This is called after the environment has been loaded but before Rails
      # sets the default for the `preview_path`
      initializer "rspec_rails.action_mailer",
                  :before => "action_mailer.set_configs" do |app|
        setup_preview_path(app)
      end

    private

      def setup_preview_path(app)
        # If the action mailer railtie isn't loaded the config will not respond
        return unless supports_action_mailer_previews?(app.config)
        options = app.config.action_mailer
        config_default_preview_path(options) if config_preview_path?(options)
      end

      def config_preview_path?(options)
        # This string version check avoids loading the ActionMailer class, as
        # would happen using `defined?`. This is necessary because the
        # ActionMailer class only loads it's settings once, at load time. If we
        # load the class now any settings declared in a config block in an
        # initializer will be ignored.
        #
        # We cannot use `respond_to?(:show_previews)` here as it will always
        # return `true`.
        if ::Rails::VERSION::STRING < '4.2'
          ::Rails.env.development?
        elsif options.show_previews.nil?
          options.show_previews = ::Rails.env.development?
        else
          options.show_previews
        end
      end

      def config_default_preview_path(options)
        return unless options.preview_path.blank?
        options.preview_path = "#{::Rails.root}/spec/mailers/previews"
      end

      def supports_action_mailer_previews?(config)
        config.respond_to?(:action_mailer) &&
          config.action_mailer.respond_to?(:preview_path)
      end
    end
  end
end
