module RSpec
  module Rails
    # Fake class to document RSpec Rails configuration options. In practice,
    # these are dynamically added to the normal RSpec configuration object.
    class Configuration
      # @!method infer_spec_type_from_file_location!
      # Automatically tag specs in conventional directories with matching `type`
      # metadata so that they have relevant helpers available to them. See
      # `RSpec::Rails::DIRECTORY_MAPPINGS` for details on which metadata is
      # applied to each directory.

      # @!method render_views=(val)
      #
      # When set to `true`, controller specs will render the relevant view as
      # well. Defaults to `false`.

      # @!method render_views(val)
      # Enables view rendering for controllers specs.

      # @!method render_views?
      # Reader for currently value of `render_views` setting.
    end

    # Mappings used by `infer_spec_type_from_file_location!`.
    #
    # @api private
    DIRECTORY_MAPPINGS = {
      :controller => %w[spec controllers],
      :helper     => %w[spec helpers],
      :job        => %w[spec jobs],
      :mailer     => %w[spec mailers],
      :model      => %w[spec models],
      :request    => %w[spec (requests|integration|api)],
      :routing    => %w[spec routing],
      :view       => %w[spec views],
      :feature    => %w[spec features]
    }

    # @private
    def self.initialize_configuration(config)
      config.backtrace_exclusion_patterns << /vendor\//
      config.backtrace_exclusion_patterns << %r{ lib/rspec/rails }

      config.include RSpec::Rails::ControllerExampleGroup, :type => :controller
      config.include RSpec::Rails::HelperExampleGroup,     :type => :helper
      config.include RSpec::Rails::ModelExampleGroup,      :type => :model
      config.include RSpec::Rails::RequestExampleGroup,    :type => :request
      config.include RSpec::Rails::RoutingExampleGroup,    :type => :routing
      config.include RSpec::Rails::ViewExampleGroup,       :type => :view
      config.include RSpec::Rails::FeatureExampleGroup,    :type => :feature

      if defined?(ActionMailer)
        config.include RSpec::Rails::MailerExampleGroup, :type => :mailer
      end

      if defined?(ActiveJob)
        config.include RSpec::Rails::JobExampleGroup, :type => :job
      end

      # controller settings
      config.add_setting :infer_base_class_for_anonymous_controllers, :default => true

      # fixture support
      config.add_setting :use_transactional_fixtures, :alias_with => :use_transactional_examples
      config.add_setting :use_instantiated_fixtures
      config.add_setting :global_fixtures
      config.add_setting :fixture_path
      config.include RSpec::Rails::FixtureSupport, :use_fixtures

      # We'll need to create a deprecated module in order to properly report to
      # gems / projects which are relying on this being loaded globally.
      #
      # See rspec/rspec-rails#1355 for history
      #
      # @deprecated Include `RSpec::Rails::RailsExampleGroup` or
      #   `RSpec::Rails::FixtureSupport` directly instead
      config.include RSpec::Rails::FixtureSupport

      # This allows us to expose `render_views` as a config option even though it
      # breaks the convention of other options by using `render_views` as a
      # command (i.e. `render_views = true`), where it would normally be used
      # as a getter. This makes it easier for rspec-rails users because we use
      # `render_views` directly in example groups, so this aligns the two APIs,
      # but requires this workaround:
      config.add_setting :rendering_views, :default => false

      config.instance_exec do
        def render_views=(val)
          self.rendering_views = val
        end

        def render_views
          self.rendering_views = true
        end

        def render_views?
          rendering_views
        end

        def infer_spec_type_from_file_location!
          DIRECTORY_MAPPINGS.each do |type, dir_parts|
            escaped_path = Regexp.compile(dir_parts.join('[\\\/]') + '[\\\/]')
            define_derived_metadata(:file_path => escaped_path) do |metadata|
              metadata[:type] ||= type
            end
          end
        end
      end
    end

    initialize_configuration RSpec.configuration
  end
end
