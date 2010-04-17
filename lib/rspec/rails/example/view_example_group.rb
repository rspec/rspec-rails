require 'webrat'

module ViewExampleGroupBehaviour
  include Webrat::Matchers
  include Rspec::Matchers

  class ViewExampleController < ActionController::Base
    attr_accessor :controller_path
  end

  module ViewExtension
    def protect_against_forgery?; end
    def method_missing(name, *args)
      if controller.respond_to?(name) || Rails.application.routes.named_routes.helpers.include?(name)
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
    running_example.example_group.description
  end

  def controller_path
    parts = file_to_render.split('/')
    parts.pop
    parts.join('/')
  end

  def render
    @response = view.render :file => file_to_render
  end

  def method_missing(selector, *args)
    if Rails.application.routes.named_routes.helpers.include?(selector)
      controller.__send__(selector, *args)
    else
      super
    end
  end

  Rspec.configure do |c|
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
