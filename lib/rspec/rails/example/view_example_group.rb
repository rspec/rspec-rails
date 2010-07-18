require 'rspec/rails/view_assigns'

module RSpec::Rails
  # Extends ActionView::TestCase::Behavior
  #
  # == Examples
  #
  #   describe "widgets/index.html.erb" do
  #     it "renders the @widgets" do
  #       widgets = [
  #         stub_model(Widget, :name => "Foo"),
  #         stub_model(Widget, :name => "Bar")
  #       ]
  #       assign(:widgets, widgets)
  #       render
  #       rendered.should contain("Foo")
  #       rendered.should contain("Bar")
  #     end
  #   end
  module ViewExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::SetupAndTeardownAdapter
    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionView::TestCase::Behavior
    include RSpec::Rails::ViewAssigns
    include Webrat::Matchers
    include RSpec::Rails::Matchers::RenderTemplate

    module ClassMethods
      def _default_helper
        base = metadata[:behaviour][:description].split('/').first
        (base.camelize + 'Helper').constantize if base
      rescue NameError
        nil
      end

      def _default_helpers
        helpers = [_default_helper].compact
        helpers << ApplicationHelper if Object.const_defined?('ApplicationHelper')
        helpers
      end
    end

    module InstanceMethods
      # :call-seq:
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
        # TODO - this is a temporary hack to achieve behaviour that is in rails edge
        # as of http://github.com/rails/rails/commit/0e0df4b0c5df7fdd1daa5653c255c4737f5526fc,
        # but is not part of the rails-3.0.0.beta4 release. This line can be removed as
        # soon as either rails 3 beta5 or rc is released.
        _assigns.each { |key, value| view.instance_variable_set("@#{key}", value) }

        options = {:template => _default_file_to_render} if Hash === options and options.empty?
        super(options, local_assigns, &block)
      end

      # The instance of ActionView::Base that is used to render the template.
      # Use this before the +render+ call to stub any methods you want to stub
      # on the view:
      #
      #   describe "widgets/new.html.erb" do
      #     it "shows all the widgets" do
      #       view.stub(:foo) { "foo" }
      #       render
      #       ...
      #     end
      #   end
      def view
        _view
      end

      # Provides access to the params hash that will be available within the
      # view:
      #
      #       params[:foo] = 'bar'
      def params
        controller.params
      end

      # Deprecated. Use +view+ instead.
      def template
        RSpec.deprecate("template","view")
        view
      end

      # Deprecated. Use +rendered+ instead.
      def response
        RSpec.deprecate("response", "rendered")
        rendered
      end

    private

      def _default_file_to_render
        example.example_group.top_level_description
      end

      def _controller_path
        _default_file_to_render.split("/")[0..-2].join("/")
      end

      def _include_controller_helpers
        helpers = controller._helpers
        view.singleton_class.class_eval do
          include helpers unless included_modules.include?(helpers)
        end
      end
    end

    included do
      metadata[:type] = :view
      helper *_default_helpers

      before do
        _include_controller_helpers
        controller.controller_path = _controller_path
        # this won't be necessary if/when
        # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4903
        # is accepted and released
        @request ||= controller.request
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','views')
  end
end
