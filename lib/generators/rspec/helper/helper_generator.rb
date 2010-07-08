require 'generators/rspec'

module Rspec
  module Generators
    class HelperGenerator < Base
      class_option :helpers, :type => :boolean, :default => true

      def create_helper_files
        return unless options[:helpers]

        template 'helper_spec.rb', File.join('spec/helpers', class_path, "#{file_name}_helper_spec.rb")
      end
    end
  end
end
