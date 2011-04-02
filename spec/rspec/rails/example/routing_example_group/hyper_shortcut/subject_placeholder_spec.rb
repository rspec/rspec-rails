require 'spec_helper'

module RSpec::Rails::HyperShortcut
  describe SubjectPlaceholder do
    let(:group) { stub(:group).as_null_object }
    let(:request_pair) { stub(:request_pair).as_null_object }
    let(:stubbed_elements) { stub(:it_block => proc{}).as_null_object}

    before :each do
      @subject_placeholder = SubjectPlaceholder.new group, request_pair
    end

    describe "should(matcher_placeholder)", "[integrations]" do
        let(:matcher_placeholder) {stub(:matcher_placeholder).as_null_object}
        after(:each){@subject_placeholder.should(matcher_placeholder)}

        it "should call Behavior.new(:should,matcher_placeholder)" do
          ShortcutElements.stub!(:new).and_return(stubbed_elements)
          Behavior.should_receive(:new).with(:should,matcher_placeholder)
        end

        it "should call describe_my(behavior)" do
          behavior = stub(:behavior).as_null_object
          Behavior.stub!(:new).and_return(behavior)
          @subject_placeholder.should_receive(:describe_my)
                              .with(behavior)
        end
    end

    describe "should_not(matcher_placeholder)", "[integrations]" do
        let(:matcher_placeholder) {stub(:matcher_placeholder).as_null_object}
        after(:each){@subject_placeholder.should_not(matcher_placeholder)}

        it "should call Behavior.new(:should_not,matcher_placeholder)" do
          ShortcutElements.stub!(:new).and_return(stubbed_elements)
          Behavior.should_receive(:new).with(:should_not,matcher_placeholder)
        end

        it "should call describe_my(behavior)" do
          behavior = stub(:behavior).as_null_object
          Behavior.stub!(:new).and_return(behavior)
          @subject_placeholder.should_receive(:describe_my)
                              .with(behavior)
        end
    end

    describe "describe_my(behavior)", "[integrations]" do
        let(:behavior) {stub(:behavior).as_null_object}
        after(:each){@subject_placeholder.describe_my(behavior)}
        it "should call ShortcutElements.new(request_pair,behavior)" do
          ShortcutElements.should_receive(:new)
                          .with(request_pair,behavior)
                          .and_return(stubbed_elements)
        end

        it "should call elements.description" do
          elements = stubbed_elements
          ShortcutElements.stub!(:new).and_return(elements)
          elements.should_receive :description
        end

        it "should call group.describe(description)" do
          stubbed_elements.stub!(:description).and_return(:description)
          ShortcutElements.stub!(:new).and_return(stubbed_elements)
          group.should_receive(:describe)
               .with(:description)
               .and_return(stub.as_null_object)
        end

        it "should call elements.it_block" do
          elements = stub.as_null_object
          ShortcutElements.stub!(:new).and_return(elements)
          elements.should_receive(:it_block)
                  .and_return(proc{})
        end
    end
  end
end
