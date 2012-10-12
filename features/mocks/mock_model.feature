Feature: mock_model

  The `mock_model` method generates a test double that acts like an instance of
  `ActiveModel`. This is different from the `stub_model` method which generates
  an instance of a real model class.

  The benefit of `mock_model` over `stub_model` is that it is a true double, so
  the examples are not dependent on the behavior (or mis-behavior), or even the
  existence of any other code. If you're working on a controller spec and you
  need a model that doesn't exist, you can pass `mock_model` a string and the
  generated object will act as though its an instance of the class named by
  that string.
   
  Scenario: passing a string that represents a non-existent constant
    Given a file named "spec/models/car_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "mock_model('Car') with no Car constant in existence" do
        it "generates a constant" do
          expect(Object.const_defined?(:Car)).to be_false
          mock_model("Car")
          expect(Object.const_defined?(:Car)).to be_true
        end

        describe "generates an object that ..." do
          it "returns the correct name" do
            car = mock_model("Car")
            expect(car.class.name).to eq("Car")
          end

          it "says it is a Car" do
            car = mock_model("Car")
            expect(car).to be_a(Car)
          end
        end
      end
      """
    When I run `rspec spec/models/car_spec.rb`
    Then the examples should all pass

  Scenario: passing a string that represents an existing constant
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Widget do
        it "uses the existing constant" do
          widget = mock_model("Widget")
          expect(widget).to be_a(Widget)
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: passing a class that does not extend ActiveModel::Naming
    Given a file named "spec/models/string_spec.rb" with:
      """ruby
      require "spec_helper"

      describe String do
        it "raises" do
          expect { mock_model(String) }.to raise_exception
        end
      end
      """
    When I run `rspec spec/models/string_spec.rb`
    Then the examples should all pass

  Scenario: passing an Active Record constant
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Widget do
        let(:widget) { mock_model(Widget) }

        it "is valid by default" do
          expect(widget).to be_valid
        end

        it "is not a new record by default" do
          expect(widget).not_to be_new_record
        end

        it "can be converted to a new record" do
          expect(widget.as_new_record).to be_new_record
        end

        it "sets :id to nil upon destroy" do
          widget.destroy
          expect(widget.id).to be_nil
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: passing an Active Record constant with method stubs
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "mock_model(Widget) with stubs" do
        let(:widget) do
          mock_model Widget, :foo => "bar",
                             :save => true,
                             :update_attributes => false
        end

        it "supports stubs for methods that don't exist in ActiveModel or ActiveRecord" do
          expect(widget.foo).to eq("bar")
        end

        it "supports stubs for methods that do exist" do
          expect(widget.save).to eq(true)
          expect(widget.update_attributes).to be_false
        end

        describe "#errors" do
          context "with update_attributes => false" do
            it "is not empty" do
              expect(widget.errors).not_to be_empty
            end
          end
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass

  Scenario: mock_model outside rails
    Given a file named "mock_model_outside_rails_spec.rb" with:
      """ruby
      require 'rspec/rails/mocks'

      describe "Foo" do
        it "is mockable" do
          foo = mock_model("Foo")
          expect(foo.id).to eq(1001)
          expect(foo.to_param).to eq("1001")
        end
      end
      """
    When I run `rspec mock_model_outside_rails_spec.rb`
    Then the examples should all pass
