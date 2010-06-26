require "spec_helper"

module RSpec::Rails
  describe RoutingExampleGroup do
    it { should be_included_in_files_in('./spec/routing/') }
    it { should be_included_in_files_in('.\\spec\\routing\\') }
  end
end
