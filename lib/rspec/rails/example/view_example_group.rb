require 'webrat'

module ViewExampleGroupBehaviour
  include Webrat::Matchers

  class ViewExampleController < ActionController::Base; end

  module ViewExtensions
    def protect_against_forgery?; end
  end

  def view
    @view ||= begin
                view = ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
                view.extend ViewExtensions
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

  def render
    @response = view.render :file => running_example.metadata[:example_group][:description]
  end

  def method_missing(selector, *args)
    if ActionController::Routing::Routes.named_routes.helpers.include?(selector)
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
    @controller ||= ViewExampleController.new
  end

end
