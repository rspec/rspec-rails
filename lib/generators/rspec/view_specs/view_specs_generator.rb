require 'generators/rspec'

module Rspec
  module Generators
    class ViewSpecsGenerator < Base
      include Rails::Generators::ResourceHelpers
      class_option :view_specs, :type => :boolean, :default => true
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :singleton, :type => :boolean, :desc => "Supply to create a singleton controller"

      class_option :controller_specs, :type => :boolean, :default => true,  :desc => "Generate controller specs"
      class_option :view_specs,       :type => :boolean, :default => true,  :desc => "Generate view specs"
      class_option :webrat_matchers,  :type => :boolean, :default => false, :desc => "Use webrat matchers in view specs"
      class_option :helper_specs,     :type => :boolean, :default => true,  :desc => "Generate helper specs"
      class_option :routing_specs,    :type => :boolean, :default => true,  :desc => "Generate routing specs"

      def generate_view_specs
        return unless options[:view_specs]

        copy_view :edit
        copy_view :index unless options[:singleton]
        copy_view :new
        copy_view :show
      end
      protected
        def webrat?
          options[:webrat_matchers] || @webrat_matchers_requested
        end

        def copy_view(view)
          template "#{view}_spec.rb",
                   File.join("spec/views", controller_file_path, "#{view}.html.#{options[:template_engine]}_spec.rb")
        end
        def value_for(attribute)
          case attribute.type
          when :string
            "#{attribute.name.titleize}".inspect
          else
            attribute.default.inspect
          end
        end
    end
  end
end
