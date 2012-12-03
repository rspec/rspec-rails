require 'spec_helper'

describe ::ActiveModel::Validations do
  describe "#errors_on" do

    context "ActiveResource" do
      let(:klass) {
        Class.new(ActiveResource::Base) do
          self.site = "fake"
          def self.name
            "ErrorOnTestClass"
          end
          validates_presence_of :name
        end
      }

      context "with nil name" do
        let(:object) { klass.new :name => ""}

        it "has one error" do
          expect(object).to have(1).error_on(:name)
        end
      end

      context "with non-blank name" do
        let(:object) { klass.new :name => "a name"}

        it "has no error" do
          expect(object).to have(:no).error_on(:name)
        end
      end
    end
  end
end
