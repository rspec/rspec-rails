require 'generators/rspec'

module Rspec
  module Generators
    class HelperGenerator < Base
      class_option :helper_specs, :type => :boolean, :default => true

      def create_helper_files
        return unless options[:helper_specs]

        template 'helper_spec.rb', File.join('spec/helpers', class_path, "#{file_name}_helper_spec.rb")
      end
    end
  end
end
