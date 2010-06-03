module RSpec
  module Rails
    class Railtie < ::Rails::Railtie
      config.generators.integration_tool :rspec
      config.generators.test_framework   :rspec
    end
  end
end
