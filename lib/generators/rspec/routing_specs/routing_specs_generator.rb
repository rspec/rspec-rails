require 'generators/rspec'

module Rspec
  module Generators
    class RoutingSpecsGenerator < Base
      include Rails::Generators::ResourceHelpers
      class_option :routing_specs, :type => :boolean, :default => true

      def generate_routing_spec
        return unless options[:routing_specs]

        template 'routing_spec.rb',
          File.join('spec/routing', controller_class_path, "#{controller_file_name}_routing_spec.rb")
      end
    end
  end
end
