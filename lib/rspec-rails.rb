module RSpec
  module Rails
    class Railtie < ::Rails::Railtie
      config.generators.integration_tool :rspec
      config.generators.test_framework   :rspec

      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end
    end
  end
end
