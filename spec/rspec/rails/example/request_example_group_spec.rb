require "spec_helper"

module RSpec::Rails
  describe RequestExampleGroup do
    it { should be_included_in_files_in('./spec/requests/') }
    it { should be_included_in_files_in('.\\spec\\requests\\') }
  end
end
