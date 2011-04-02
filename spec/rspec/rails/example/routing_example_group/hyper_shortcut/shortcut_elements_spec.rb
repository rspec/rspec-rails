require 'spec_helper'

module RSpec::Rails::HyperShortcut
  describe ShortcutElements do
    let(:request_pair) { stub(:request_pair).as_null_object }
    let(:behavior) { mock(:behavior).as_null_object }

    before :each do
      @shortcut_elements = ShortcutElements.new request_pair, behavior
    end


    describe "description()" do

      describe "integrations" do
        it "should call request_pair.to_s" do
          request_pair.should_receive :to_s
        end
        after(:each) {@shortcut_elements.description}
      end

      describe "return" do
        before :each do
          request_pair.stub!(:to_s).and_return String.new
        end
        subject {@shortcut_elements.description}
        it {should be_a String}
      end

    end


    describe "it_block()" do

      describe "integrations" do
        after(:each) {@shortcut_elements.it_block}

        it "should call request_pair.to_hash" do
          request_pair.should_receive(:to_hash)
        end

        it "should call behavior.block_to_test" do
          request_pair.stub!(:to_hash).and_return(:hash)
          behavior.should_receive(:block_to_test).with(:hash)
        end
      end

      describe "return" do
        before :each do
          request_pair.stub!(:to_hash)
          behavior.stub!(:block_to_test).and_return(proc{})
        end
        subject {@shortcut_elements.it_block}
        it {should be_a Proc}
      end

    end

  end
end
