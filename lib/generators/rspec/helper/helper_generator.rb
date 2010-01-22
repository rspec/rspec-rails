require 'generators/rspec'

module Rspec
  module Generators
    class HelperGenerator < Base
      def create_helper_files
        template 'helper_spec.rb', File.join('spec/helpers', class_path, "#{file_name}_helper_spec.rb")
      end
    end
  end
end
