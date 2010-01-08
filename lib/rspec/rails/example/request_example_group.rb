require 'action_dispatch'
require 'webrat'

module RequestExampleGroupBehaviour
  include ActionDispatch::Assertions
  include ActionDispatch::Integration::Runner
  include Webrat::Matchers
  include Webrat::Methods
  Rails.application.routes.install_helpers(self)

  def app
    Rails.application
  end

  Webrat.configure do |config|
    config.mode = :rack
  end

  def last_response
    response
  end
  
  Rspec::Core.configure do |c|
    c.include self
   # , :behaviour => { :describes => /^\// }
  end
end

# describe "/widgets" do
  # context "GET index" do
    # it "does something" do
      # visit widgets_path
      # response.body.should == "this text"
      # response.should contain("this text")
      # response.should have_selector('p:contains("that")')
    # end
  # end
# end

