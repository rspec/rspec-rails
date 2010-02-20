require 'spec_helper'

describe "/<%= file_name %>/<%= @action %>.html.<%= options[:template_engine] %>" do
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    render
    response.should have_selector('p', :content => "Find me in app/views/<%= file_path %>/<%= @action %>")
  end
end
