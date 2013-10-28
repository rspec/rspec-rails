require 'rspec/rails/example/rails_example_group'
require 'rspec/rails/example/controller_example_group'
require 'rspec/rails/example/request_example_group'
require 'rspec/rails/example/helper_example_group'
require 'rspec/rails/example/view_example_group'
require 'rspec/rails/example/mailer_example_group'
require 'rspec/rails/example/routing_example_group'
require 'rspec/rails/example/model_example_group'
require 'rspec/rails/example/feature_example_group'

RSpec::configure do |c|
  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]') + '[\\\/]')
  end

  controller_path_regex = c.escaped_path(%w[spec controllers])
  c.include RSpec::Rails::ControllerExampleGroup,
    :type          => :controller,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && controller_path_regex =~ example_group[:file_path]
    }

  helper_path_regex = c.escaped_path(%w[spec helpers])
  c.include RSpec::Rails::HelperExampleGroup,
    :type          => :helper,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && helper_path_regex =~ example_group[:file_path]
    }

  mailer_path_regex = c.escaped_path(%w[spec mailers])
  if defined?(RSpec::Rails::MailerExampleGroup)
    c.include RSpec::Rails::MailerExampleGroup,
      :type          => :mailer,
      :example_group => lambda { |example_group, metadata|
        metadata[:type].nil? && mailer_path_regex =~ example_group[:file_path]
      }
  end

  model_path_regex = c.escaped_path(%w[spec models])
  c.include RSpec::Rails::ModelExampleGroup,
    :type          => :model,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && model_path_regex =~ example_group[:file_path]
    }

  request_path_regex = c.escaped_path(%w[spec (requests|integration|api)])
  c.include RSpec::Rails::RequestExampleGroup,
    :type          => :request,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && request_path_regex =~ example_group[:file_path]
    }

  routing_path_regex = c.escaped_path(%w[spec routing])
  c.include RSpec::Rails::RoutingExampleGroup,
    :type          => :routing,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && routing_path_regex =~ example_group[:file_path]
    }

  view_path_regex = c.escaped_path(%w[spec views])
  c.include RSpec::Rails::ViewExampleGroup,
    :type          => :view,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && view_path_regex =~ example_group[:file_path]
    }

  feature_example_regex = c.escaped_path(%w[spec features])
  c.include RSpec::Rails::FeatureExampleGroup,
    :type          => :feature,
    :example_group => lambda { |example_group, metadata|
      metadata[:type].nil? && feature_example_regex =~ example_group[:file_path]
    }
end
