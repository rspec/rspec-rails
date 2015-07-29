require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class FeatureGenerator < Base
      class_option :feature_specs, :type => :boolean, :default => true, :desc => "Generate feature specs"

      def generate_feature_spec
        return unless options[:feature_specs]
        file_name = table_name.parameterize.underscore

        template 'feature_spec.rb', File.join('spec/features', class_path, "#{file_name}_spec.rb") # file_name?
      end
    end
  end
end
