require 'generators/rspec'

module Rspec
  module Generators
    class IntegrationGenerator < Base
      def create_integration_file
        template 'request_spec.rb',
                 File.join('spec/requests', class_path, "#{table_name}_spec.rb")
      end
    end
  end
end
