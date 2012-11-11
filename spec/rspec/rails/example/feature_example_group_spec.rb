require "spec_helper"

module RSpec::Rails
  describe FeatureExampleGroup do
    it { should be_included_in_files_in('./spec/features/') }
    it { should be_included_in_files_in('.\\spec\\features\\') }

    it "adds :type => :model to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include FeatureExampleGroup
      end

      expect(group.metadata[:type]).to eql(:feature)
    end

    it "includes Rails route helpers" do
      Rails.application.routes.draw do
        get "/foo", :as => :foo, :to => "foo#bar"
      end

      group = RSpec::Core::ExampleGroup.describe do
        include FeatureExampleGroup
      end

      expect(group.new.foo_path).to eql("/foo")
      expect(group.new.foo_url).to eql("http://www.example.com/foo")
    end

    describe "#visit" do
      it "raises an error informing about missing Capybara" do
        group = RSpec::Core::ExampleGroup.describe do
          include FeatureExampleGroup
        end

        expect {
          group.new.visit('/foobar')
        }.to raise_error(/Capybara not loaded/)
      end

      it "is resistant to load order errors" do
        capybara = Module.new do
          def visit(url)
            "success: #{url}"
          end
        end

        group = RSpec::Core::ExampleGroup.describe do
          include capybara
          include FeatureExampleGroup
        end

        expect(group.new.visit("/foo")).to eql("success: /foo")
      end
    end
  end
end
