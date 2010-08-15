Feature: mock_model

  As a Rails developer using RSpec
  In order to mock an Active Record model
  I want to use mock_model

  Scenario: passing a string that is not an existing constant
    Given a file named "spec/models/car_spec.rb" with:
      """
      require "spec_helper"

      describe "Car" do
        it "converts to a constant" do
          car = mock_model("Car")
          Object.should be_const_defined(:Car)
        end

        it "returns the correct name" do
          car = mock_model("Car")
          car.class.name.should eql("Car")
        end
      end
      """
    When I run "rspec spec/models/car_spec.rb"
    Then the output should contain "2 examples, 0 failures"

  Scenario: passing a string that is an existing constant
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        it "gets the constant" do
          widget = mock_model("Widget")
          widget.should be_a(Widget)
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: passing a constant that is not extendable
    Given a file named "spec/models/string_spec.rb" with:
      """
      require "spec_helper"

      describe String do
        it "raises" do
          expect { mock_model(String) }.to raise_exception
        end
      end
      """
    When I run "rspec spec/models/string_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: passing an AR constant and invoking its methods
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        let(:widget) { mock_model(Widget) }

        it "is valid by default" do
          widget.should be_valid
        end

        it "is not a new record by default" do
          widget.should_not be_new_record
        end

        it "can be converted to a new record" do
          widget.as_new_record.should be_new_record
        end

        it "sets :id to nil upon destroy" do
          widget.destroy
          widget.id.should be_nil
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"

  Scenario: passing an AR constant with method mocks
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        let(:widget) do
          mock_model Widget, :foo => "bar",
                             :save => true,
                             :update_attributes => false
        end

        it "calls foo successfully" do
          widget.foo.should eql("bar")
        end

        it "calls save and returns true" do
          widget.save.should eql(true)
        end

        it "calls update_attributes and returns false" do
          widget.update_attributes.should be_false
        end

        it "calls update_attributes and produces errors" do
          widget.update_attributes
          widget.errors.should_not be_empty
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"