require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../../spec_helper')

describe "/<%= file_name %>/<%= @action %>.html.<%= options[:template_engine] %>" do
  before(:each) do
    render '<%= file_name %>/<%= @action %>'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/<%= file_path %>/<%= @action %>])
  end
end
