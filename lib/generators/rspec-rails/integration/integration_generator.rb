require 'generators/rspec'

module Rspec
  module Generators
    class IntegrationGenerator < Base
      def create_integration_file
        template 'integration_spec.rb',
                 File.join('spec/integration', class_path, "#{table_name}_spec.rb")
      end
    end
  end
end
