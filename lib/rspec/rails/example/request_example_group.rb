require 'rspec/rails/core/example/request_example_group'
require 'webrat'

module RequestExampleGroupBehaviour
  include Webrat::Matchers
  include Webrat::Methods

  # add factory_girl

  Webrat.configure do |config|
    config.mode = :rack
  end

  def last_response
    response
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
