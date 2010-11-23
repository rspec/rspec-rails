module RSpec
  module Rails
    class Railtie < ::Rails::Railtie
      # Rails-3.0.1 requires config.app_generators instead of 3.0.0's config.generators
      generators = config.respond_to?(:app_generators) ? config.app_generators : config.generators
      generators.test_framework  :rspec
      generators.integration_tool :rspec
      generators.routing_specs =  :rspec unless generators.view_specs
      generators.controller_specs =  :rspec unless generators.view_specs
      generators.view_specs =  :rspec unless generators.view_specs

      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end
    end
  end
end
