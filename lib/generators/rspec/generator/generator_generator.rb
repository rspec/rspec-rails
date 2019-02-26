require 'generators/rspec'

if ::Rails::VERSION::STRING >= '5.1'
  module Rspec
    module Generators
      # @private
      class GeneratorGenerator < Base
        class_option :generator_specs, :type => :boolean, :default => true,  :desc => "Generate generator specs"

        def generate_generator_spec
          return unless options[:generator_specs]

          template template_name, File.join('spec/generator', class_path, filename)
        end

        def template_name
          'generator_spec.rb'
        end

        def filename
          "#{table_name}_generator_spec.rb"
        end
      end
    end
  end
end
