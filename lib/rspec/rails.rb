require 'rspec/core'
require 'rails/version'

module RSpec
  module Rails
    autoload :RailsExampleGroup, 'rspec/rails/example/rails_example_group'
    autoload :ControllerExampleGroup, 'rspec/rails/example/controller_example_group'
    autoload :HelperExampleGroup, 'rspec/rails/example/helper_example_group'
    autoload :ModelExampleGroup, 'rspec/rails/example/model_example_group'
    autoload :RequestExampleGroup, 'rspec/rails/example/request_example_group'
    autoload :RoutingExampleGroup, 'rspec/rails/example/routing_example_group'
    autoload :ViewExampleGroup, 'rspec/rails/example/view_example_group'
    autoload :FeatureExampleGroup, 'rspec/rails/example/feature_example_group'
    autoload :SystemExampleGroup, 'rspec/rails/example/system_example_group'
    autoload :MailerExampleGroup, 'rspec/rails/example/mailer_example_group'
    autoload :JobExampleGroup, 'rspec/rails/example/job_example_group'
    autoload :ChannelExampleGroup, 'rspec/rails/example/channel_example_group'
    autoload :MailboxExampleGroup, 'rspec/rails/example/mailbox_example_group'
  end
end

# Load any of our adapters and extensions early in the process
require 'rspec/rails/adapters'
require 'rspec/rails/extensions'

# Load the rspec-rails parts
require 'rspec/rails/view_rendering'
require 'rspec/rails/matchers'
require 'rspec/rails/fixture_support'
require 'rspec/rails/file_fixture_support'
require 'rspec/rails/fixture_file_upload_support'
require 'rspec/rails/vendor/capybara'
require 'rspec/rails/configuration'
require 'rspec/rails/active_record'
require 'rspec/rails/feature_check'
require 'rspec/rails/view_assigns'
require 'rspec/rails/view_path_builder'
require 'rspec/rails/view_spec_methods'
