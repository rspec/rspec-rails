require 'generators/rspec'
require 'rails/generators/resource_helpers'

module Rspec
  module Generators
    class ScaffoldGenerator < Base
      include Rails::Generators::ResourceHelpers
      source_paths << File.expand_path("../../helper/templates", __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :singleton, :type => :boolean, :desc => "Supply to create a singleton controller"

      class_option :controller_specs, :type => :boolean, :default => true,  :desc => "Generate controller specs"
      class_option :view_specs,       :type => :boolean, :default => true,  :desc => "Generate view specs"
      class_option :webrat_matchers,  :type => :boolean, :default => false, :desc => "Use webrat matchers in view specs"
      class_option :helper_specs,     :type => :boolean, :default => true,  :desc => "Generate helper specs"
      class_option :routing_specs,    :type => :boolean, :default => true,  :desc => "Generate routing specs"

      hook_for :controller_specs
      hook_for :view_specs


      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold do |invoked|
        invoke invoked, [ controller_name ]
      end

      hook_for :routing_specs

      hook_for :integration_tool, :as => :integration

      protected
        def banner
          self.class.banner
        end
    end
  end
end
