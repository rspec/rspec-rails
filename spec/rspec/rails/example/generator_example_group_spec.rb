require "spec_helper"

module RSpec::Rails
  describe GeneratorExampleGroup do
    it { should be_included_in_files_in('./spec/generators/') }
    it { should be_included_in_files_in('.\\spec\\generators\\') }

    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        include GeneratorExampleGroup
      end
    end

    it "adds :type => :generator to the metadata" do
      group.metadata[:type].should eq(:generator)
    end

    context "with implicit subject" do
      it "uses the generator as the subject" do
        generator = double('generator')
        example = group.new
        example.stub(:generator => generator)
        example.subject.should == generator
      end
    end

    describe "with explicit subject" do
      it "should use the specified subject instead of the generator" do
        group.subject { 'explicit' }
        example = group.new
        example.subject.should == 'explicit'
      end
    end
  end
end
