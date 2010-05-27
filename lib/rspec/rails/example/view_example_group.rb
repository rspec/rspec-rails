require 'webrat'
require 'rspec/rails/view_assigns'

module ViewExampleGroupBehaviour
  extend  ActiveSupport::Concern

  include RSpec::Rails::SetupAndTeardownAdapter
  include RSpec::Rails::TestUnitAssertionAdapter
  include ActionView::TestCase::Behavior
  include RSpec::Rails::ViewAssigns
  include Webrat::Matchers

  module InstanceMethods
    def response
      RSpec.deprecate("response", "rendered")
      rendered
    end

    # :callseq:
    #   render 
    #   render(:template => "widgets/new.html.erb")
    #   render({:partial => "widgets/widget.html.erb"}, {... locals ...})
    #   render({:partial => "widgets/widget.html.erb"}, {... locals ...}) do ... end
    #
    # Delegates to ActionView::Base#render, so see documentation on that for more
    # info.
    #
    # The only addition is that you can call render with no arguments, and RSpec
    # will pass the top level description to render:
    #
    #   describe "widgets/new.html.erb" do
    #     it "shows all the widgets" do
    #       render # => view.render(:file => "widgets/new.html.erb")
    #       ...
    #     end
    #   end
    def render(options={}, local_assigns={}, &block)
      options = {:template => _default_file_to_render} if Hash === options and options.empty?
      super(options, local_assigns, &block)
    end

  private

    def _default_file_to_render
      running_example.example_group.top_level_description
    end

    def _controller_path
      _default_file_to_render.split("/")[0..-2].join("/")
    end
  end

  included do
    before do
      controller.controller_path = _controller_path
    end
  end

  RSpec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/views\// }
  end
end
