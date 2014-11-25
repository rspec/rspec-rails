require 'rspec/rails/view_assigns'

module RSpec
  module Rails
    # Container module for helper specs.
    module HelperExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include ActionView::TestCase::Behavior

      def assign(instance_variable_name, value)
        [helper, controller].each do |object|
          object.instance_variable_set("@#{instance_variable_name}", value)
        end
      end

    private

      included do
        let(:controller_class) do
          controller_class_name = described_class.name.gsub("Helper", "Controller")
          if Object.const_defined?(controller_class_name)
            Object.const_get(controller_class_name.to_sym)
          elsif defined?(ApplicationController)
            ApplicationController
          else
            ActionController::Base
          end
        end

        let(:controller) { controller_class.new }

        let(:helper) do
          @controller = controller
          view.extend(ApplicationHelper) if defined?(ApplicationHelper)
          view.extend(described_class)
          view
        end

        subject { helper }
      end
    end
  end
end
