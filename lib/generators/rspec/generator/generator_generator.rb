require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class GeneratorGenerator < Base
      class_option :namespace, :type => :boolean, :default => true,
                               :desc => "Namespace generator under lib/generators/name"

      def generate_generator_spec
        template 'generator_spec.rb', File.join('spec/lib/generators', class_path, "#{file_name}_generator_spec.rb")
      end

    private

      def generator_path
        if options[:namespace]
          File.join("generators", class_path, file_name, "#{file_name}_generator")
        else
          File.join("generators", class_path, "#{file_name}_generator")
        end
      end
    end
  end
end
