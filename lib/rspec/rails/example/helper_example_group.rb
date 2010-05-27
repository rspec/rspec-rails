require 'webrat'
require 'rspec/rails/view_assigns'

module HelperExampleGroupBehaviour
  extend  ActiveSupport::Concern

  include RSpec::Rails::SetupAndTeardownAdapter
  include RSpec::Rails::TestUnitAssertionAdapter
  include ActionView::TestCase::Behavior
  include RSpec::Rails::ViewAssigns
  include Webrat::Matchers

  module ClassMethods
    def determine_default_helper_class(ignore)
      describes
    end
  end

  module InstanceMethods
    # Returns an instance of ActionView::Base instrumented with this helper and
    # any of the built-in rails helpers.
    def helper
      _view
    end

  private

    def _controller_path
      running_example.example_group.describes.to_s.sub(/Helper/,'').underscore
    end
  end

  included do
    before do
      controller.controller_path = _controller_path
    end
  end

  RSpec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/helpers\// }
  end
end

