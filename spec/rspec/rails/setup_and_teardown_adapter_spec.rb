require 'spec_helper'

describe RSpec::Rails::SetupAndTeardownAdapter do
  describe "::setup" do
    it "registers before hooks in the order setup is received" do
      klass = Class.new do
        include RSpec::Rails::SetupAndTeardownAdapter
        def self.foo; "foo"; end
        def self.bar; "bar"; end
      end
      klass.should_receive(:before).ordered { |&block| block.call.should eq "foo" }
      klass.should_receive(:before).ordered { |&block| block.call.should eq "bar" }

      klass.setup :foo
      klass.setup :bar
    end

    it "registers prepend_before hooks for the Rails' setup methods" do
      klass = Class.new do
        include RSpec::Rails::SetupAndTeardownAdapter
        def self.setup_fixtures; "setup fixtures"  end
        def self.setup_controller_request_and_response; "setup controller"  end
      end

      klass.should_receive(:prepend_before) { |&block| block.call.should eq "setup fixtures" }
      klass.should_receive(:prepend_before) { |&block| block.call.should eq "setup controller" }

      klass.setup :setup_fixtures
      klass.setup :setup_controller_request_and_response
    end
  end
end
