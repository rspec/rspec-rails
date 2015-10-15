require 'generators/rspec/integration/integration_generator'

# @private
module Rspec
  module Generators
    # @private
    class RequestGenerator < IntegrationGenerator
      source_paths << File.expand_path("../../integration/templates", __FILE__)
    end
  end
end
