module RSpec
  module Rails
    # @private
    def self.initialize_configuration(config)
      config.backtrace_exclusion_patterns << /vendor\//
      config.backtrace_exclusion_patterns << /lib\/rspec\/rails/

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

      # controller settings
      config.add_setting :infer_base_class_for_anonymous_controllers, :default => true

      # fixture support
      config.include     RSpec::Rails::FixtureSupport
      config.add_setting :use_transactional_fixtures, :alias_with => :use_transactional_examples
      config.add_setting :use_instantiated_fixtures
      config.add_setting :global_fixtures
      config.add_setting :fixture_path

      # view rendering settings
      # This allows us to expose `render_views` as a config option even though it
      # breaks the convention of other options by using `render_views` as a
      # command (i.e. render_views = true), where it would normally be used as a
      # getter. This makes it easier for rspec-rails users because we use
      # `render_views` directly in example groups, so this aligns the two APIs,
      # but requires this workaround:
      config.add_setting :rendering_views, :default => false

      # @private
      # TODO: How to YARD this? Not actually private.
      def config.render_views=(val)
        self.rendering_views = val
      end

      # @private
      # TODO: How to YARD this? Not actually private.
      def config.render_views
        self.rendering_views = true
      end

      # @private
      # TODO: How to YARD this? Not actually private.
      def config.render_views?
        rendering_views
      end

      # @private
      # TODO: How to YARD this? Not actually private.
      def config.infer_spec_type_from_file_location!
        {
          :controller => %w[spec controllers],
          :helper     => %w[spec helpers],
          :mailer     => %w[spec mailers],
          :model      => %w[spec models],
          :request    => %w[spec (requests|integration|api)],
          :routing    => %w[spec routing],
          :view       => %w[spec views],
          :feature    => %w[spec features]
        }.each do |type, dir_parts|
          escaped_path = Regexp.compile(dir_parts.join('[\\\/]') + '[\\\/]')
          define_derived_metadata(:file_path => escaped_path) do |metadata|
            metadata[:type] ||= type
          end
        end
      end
    end

    initialize_configuration RSpec.configuration
  end
end
