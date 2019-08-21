require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class ControllerGenerator < Base
      argument :actions, :type => :array, :default => [], :banner => "action action"

      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :controller_specs, :type => :boolean, :default => true, :desc => "Generate controller specs"
      class_option :view_specs,       :type => :boolean, :default => true, :desc => "Generate view specs"
      class_option :routing_specs,    :type => :boolean, :default => false, :desc => "Generate routing specs"

      def generate_controller_spec
        return unless options[:controller_specs]

        template 'controller_spec.rb',
                 File.join('spec/controllers', class_path, "#{file_name}_controller_spec.rb")
      end

      def generate_view_specs
        return if actions.empty?
        return unless options[:view_specs] && options[:template_engine]

        empty_directory File.join("spec", "views", file_path)

        actions.each do |action|
          @action = action
          template 'view_spec.rb',
                   File.join("spec", "views", file_path, "#{@action}.html.#{options[:template_engine]}_spec.rb")
        end
      end

      def generate_routing_spec
        return if actions.empty?
        return unless options[:routing_specs]

        template 'routing_spec.rb',
                 File.join('spec/routing', class_path, "#{file_name}_routing_spec.rb")
      end
    end
  end
end
