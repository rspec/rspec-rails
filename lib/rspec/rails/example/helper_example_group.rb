module RSpec
  module Rails
    # @api public
    # Container module for helper specs.
    module HelperExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include ActionView::TestCase::Behavior
      include RSpec::Rails::ViewAssigns

      # @private
      module ClassMethods
        def determine_constant_from_test_name(_ignore)
          described_class if yield(described_class)
        end
      end

      # Returns an instance of ActionView::Base with the helper being specified
      # mixed in, along with any of the built-in rails helpers.
      def helper
        _view.tap do |v|
          v.extend(ApplicationHelper) if defined?(ApplicationHelper)
          v.assign(view_assigns)
        end
      end

    private

      def _controller_path(example)
        example.example_group.described_class.to_s.sub(/Helper/, '').underscore
      end

      included do
        before do |example|
          controller.controller_path = _controller_path(example)
        end
      end
    end
  end
end
