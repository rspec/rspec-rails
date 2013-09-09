require 'spec_helper'

describe ::ActiveModel::Validations do
  describe "#errors_on" do
    context "ActiveModel class that takes no arguments to valid?" do
      let(:klass) {
        Class.new do
          include ActiveModel::Validations

          def self.name
            "ActiveModelValidationsFake"
          end

          def valid?
            super
          end

          attr_accessor :name
          validates_presence_of :name
        end
      }

      context "with nil name" do
        it "has one error" do
          object = klass.new
          object.name = ""

          expect(object.error_on(:name).size).to eq 1
        end
      end

      context "with non-blank name" do
        it "has no error" do
          object = klass.new
          object.name = "Ywen"

          expect(object.error_on(:name).size).to eq 0
        end
      end
    end
  end
end
