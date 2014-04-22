module RSpec
  module Rails
    # @private
    def self.add_rspec_rails_config_api_to(config)
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

      def config.render_views=(val)
        self.rendering_views = val
      end

      def config.render_views
        self.rendering_views = true
      end

      def config.render_views?
        rendering_views
      end

      def config.infer_spec_type_from_file_location!
        def self.escaped_path(*parts)
          Regexp.compile(parts.join('[\\\/]') + '[\\\/]')
        end

        controller_path_regex = self.escaped_path(%w[spec controllers])
        self.include RSpec::Rails::ControllerExampleGroup,
          :type          => :controller,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && controller_path_regex =~ file_path
          }

        helper_path_regex = self.escaped_path(%w[spec helpers])
        self.include RSpec::Rails::HelperExampleGroup,
          :type          => :helper,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && helper_path_regex =~ file_path
          }

        mailer_path_regex = self.escaped_path(%w[spec mailers])
        if defined?(RSpec::Rails::MailerExampleGroup)
          self.include RSpec::Rails::MailerExampleGroup,
            :type          => :mailer,
            :file_path     => lambda { |file_path, metadata|
              metadata[:type].nil? && mailer_path_regex =~ file_path
            }
        end

        model_path_regex = self.escaped_path(%w[spec models])
        self.include RSpec::Rails::ModelExampleGroup,
          :type          => :model,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && model_path_regex =~ file_path
          }

        request_path_regex = self.escaped_path(%w[spec (requests|integration|api)])
        self.include RSpec::Rails::RequestExampleGroup,
          :type          => :request,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && request_path_regex =~ file_path
          }

        routing_path_regex = self.escaped_path(%w[spec routing])
        self.include RSpec::Rails::RoutingExampleGroup,
          :type          => :routing,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && routing_path_regex =~ file_path
          }

        view_path_regex = self.escaped_path(%w[spec views])
        self.include RSpec::Rails::ViewExampleGroup,
          :type          => :view,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && view_path_regex =~ file_path
          }

        feature_example_regex = self.escaped_path(%w[spec features])
        self.include RSpec::Rails::FeatureExampleGroup,
          :type          => :feature,
          :file_path     => lambda { |file_path, metadata|
            metadata[:type].nil? && feature_example_regex =~ file_path
          }
      end
    end
  end
end

RSpec.configure do |c|
  RSpec::Rails.add_rspec_rails_config_api_to(c)

  c.backtrace_exclusion_patterns << /vendor\//
  c.backtrace_exclusion_patterns << /lib\/rspec\/rails/

  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]') + '[\\\/]')
  end

  controller_path_regex = c.escaped_path(%w[spec controllers])
  c.include RSpec::Rails::ControllerExampleGroup,
    :type          => :controller,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && controller_path_regex =~ file_path
    }

  helper_path_regex = c.escaped_path(%w[spec helpers])
  c.include RSpec::Rails::HelperExampleGroup,
    :type          => :helper,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && helper_path_regex =~ file_path
    }

  mailer_path_regex = c.escaped_path(%w[spec mailers])
  if defined?(RSpec::Rails::MailerExampleGroup)
    c.include RSpec::Rails::MailerExampleGroup,
      :type          => :mailer,
      :file_path     => lambda { |file_path, metadata|
        metadata[:type].nil? && mailer_path_regex =~ file_path
      }
  end

  model_path_regex = c.escaped_path(%w[spec models])
  c.include RSpec::Rails::ModelExampleGroup,
    :type          => :model,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && model_path_regex =~ file_path
    }

  request_path_regex = c.escaped_path(%w[spec (requests|integration|api)])
  c.include RSpec::Rails::RequestExampleGroup,
    :type          => :request,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && request_path_regex =~ file_path
    }

  routing_path_regex = c.escaped_path(%w[spec routing])
  c.include RSpec::Rails::RoutingExampleGroup,
    :type          => :routing,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && routing_path_regex =~ file_path
    }

  view_path_regex = c.escaped_path(%w[spec views])
  c.include RSpec::Rails::ViewExampleGroup,
    :type          => :view,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && view_path_regex =~ file_path
    }

  feature_example_regex = c.escaped_path(%w[spec features])
  c.include RSpec::Rails::FeatureExampleGroup,
    :type          => :feature,
    :file_path     => lambda { |file_path, metadata|
      metadata[:type].nil? && feature_example_regex =~ file_path
    }
end
