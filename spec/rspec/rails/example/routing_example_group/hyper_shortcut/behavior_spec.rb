require 'spec_helper'

module RSpec::Rails::HyperShortcut
  describe Behavior do
    let(:matcher_placeholder) {stub(:matcher_placeholder).as_null_object}

    before :each do
      @behavior = Behavior.new :should, matcher_placeholder
      @subject = stub(:subject)
    end


    describe "block_to_test(subject)" do

      describe "return" do
        subject {@behavior.block_to_test @subject}
        it {should be_a Proc}

        context "when called" do
          it "should call placeholder.build_matcher_in(self)" do
            matcher_placeholder.should_receive(:build_matcher_in)
          end

          it "should call subject.should(matcher)" do
            @subject.should_receive(:should)
          end
          after(:each) {subject.call}
        end

      end
    end

  end
end
