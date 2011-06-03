require 'spec_helper'

describe "contain" do

  context "when the file exists" do
    let(:contents) { "This file\ncontains\nthis text" }
    let(:mock_file) { mock(:read=>contents) }

    subject { '/some/file/path' }
    before do
      File.stub(:new).with('/some/file/path').and_return(mock_file)
    end
    it { should contain "This file\ncontains\nthis text" }
    it { should contain /This file/ }
    it { should contain /this text/ }
    it { should_not contain /something not there/ }
  end
  
  context "when the file is not there" do
    it 'raises an error when the file does not exist' do
      expect do
        'some/file/that/does/not/exist'.should contain 'something'
      end.to raise_error 'No such file or directory - some/file/that/does/not/exist'
    end
  end
end
