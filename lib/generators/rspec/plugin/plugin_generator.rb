require 'generators/rspec'

module Rspec
  module Generators
    class PluginGenerator < Base
      class_option :template_engine, :desc => "Template engine to generate plugin files"
      class_option :plugin_specs, :type => :boolean, :default => true

      def create_plugin_specs
        return unless options[:plugin_specs]

        template 'plugin_spec.rb',
                 File.join('spec/plugins', "#{file_name}_spec.rb")
      end
    end
  end
end
