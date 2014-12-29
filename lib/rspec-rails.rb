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
        if ::RSpec::Rails::FeatureCheck.has_action_mailer_preview?
          options = app.config.action_mailer
          # Rails 4.1 does not have `show_previews`
          if ::ActionMailer::Base.respond_to?(:show_previews=)
            options.show_previews ||= ::Rails.env.development?
            set_preview_path = options.show_previews
          else
            set_preview_path = ::Rails.env.development?
          end

          if set_preview_path
            rspec_preview_path = "#{::Rails.root}/spec/mailers/previews"
            config_preview_path = options.preview_path
            if config_preview_path.blank?
              options.preview_path = rspec_preview_path
            elsif config_preview_path != rspec_preview_path
              warn "Action Mailer `preview_path` is not the RSpec default. " \
                   "Preview path is set to: #{config_preview_path}"
            end
          end
        end
      end
    end
  end
end
