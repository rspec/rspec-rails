require 'webrat'

module ViewExampleGroupBehaviour
  include Webrat::Matchers
  include RSpec::Matchers

  class ViewExampleController < ActionController::Base
    attr_accessor :controller_path
  end

  module ViewExtension
    def protect_against_forgery?; end
    def method_missing(name, *args)
      if controller.respond_to?(name) || helpers.include?(name)
        controller.__send__(name, *args)
      else
        super(name, *args)
      end
    end
  end

  def view
    @view ||= begin
                view = ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
                view.extend(ActionController::PolymorphicRoutes)
                view.extend(ViewExtension)
                view
              end
  end

  def assign(name, value)
    assigns[name] = value
  end

  def assigns
    @assigns ||= {}
  end

  def response
    @response
  end

  def file_to_render
    running_example.example_group.top_level_description
  end

  def controller_path
    parts = file_to_render.split('/')
    parts.pop
    parts.join('/')
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
  def render(options = nil, locals = {}, &block)
    options ||= {:file => file_to_render}
    @response = view.render(options, locals, &block)
  end

  def helpers
    ::Rails.application.routes.named_routes.helpers
  end

  def method_missing(selector, *args)
    if helpers.include?(selector)
      controller.__send__(selector, *args)
    else
      super
    end
  end

  RSpec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/views\// }
  end

private

  def controller
    @controller ||= begin
                      controller = ViewExampleController.new
                      controller.controller_path = controller_path
                      controller.request = ActionDispatch::Request.new(Rack::MockRequest.env_for("/url"))
                      controller
                    end
  end

end
