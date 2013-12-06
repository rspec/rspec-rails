require 'spec_helper'

describe RSpec::Rails::SetupAndTeardownAdapter do
  describe "::setup" do
    it "registers before hooks in the order setup is received" do
      klass = Class.new do
        include RSpec::Rails::SetupAndTeardownAdapter
        def self.foo; "foo"; end
        def self.bar; "bar"; end
      end
      expect(klass).to receive(:before).ordered { |&block| expect(block.call).to eq "foo" }
      expect(klass).to receive(:before).ordered { |&block| expect(block.call).to eq "bar" }

      klass.setup :foo
      klass.setup :bar
    end

    it "registers prepend_before hooks for the Rails' setup methods" do
      klass = Class.new do
        include RSpec::Rails::SetupAndTeardownAdapter
        def self.setup_fixtures; "setup fixtures"  end
        def self.setup_controller_request_and_response; "setup controller"  end
      end

      expect(klass).to receive(:prepend_before) { |&block| expect(block.call).to eq "setup fixtures" }
      expect(klass).to receive(:prepend_before) { |&block| expect(block.call).to eq "setup controller" }

      klass.setup :setup_fixtures
      klass.setup :setup_controller_request_and_response
    end
  end
end
