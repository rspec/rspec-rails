require 'webrat'

module ViewExampleGroupBehaviour
  include Webrat::Matchers

  def assign(name, value)
    assigns[name] = value
  end

  def assigns
    @assigns ||= {}
  end

  def view
    @view ||= ActionView::Base.new(ActionController::Base.view_paths, assigns)
  end

  def response
    @response
  end

  def render
    @response = view.render :file => running_example.metadata[:example_group][:description]
  end

  Rspec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/views\// }
  end
end
