require 'spec_helper'

describe "exist" do
  it 'passes when the file exists' do
    File.stub(:exists?).with('/some/file/path').and_return(true)
    '/some/file/path'.should exist
  end
  it 'fails when the file does not exist' do
    File.stub(:exists?).with('/some/file/path').and_return(false)
    '/some/file/path'.should_not exist
  end
  
end
