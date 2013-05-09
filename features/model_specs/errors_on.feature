Feature: errors_on

  Scenario: with one validation error
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        self.table_name = :widgets
        validates_presence_of :name

        # In Rails 4, mass assignment protection is implemented on controllers
        attr_accessible :name if ::Rails::VERSION::STRING < '4'

        validates_length_of :name, :minimum => 10, :on => :publication
      end

      describe ValidatingWidget do
        it "fails validation with no name (using error_on)" do
          expect(ValidatingWidget.new).to have(1).error_on(:name)
        end

        it "fails validation with no name (using errors_on)" do
          expect(ValidatingWidget.new).to have(1).errors_on(:name)
        end

        it "fails validation with no name expecting a specific message" do
          expect(ValidatingWidget.new.errors_on(:name)).to include("can't be blank")
        end

        it "fails validation with a short name (using a validation context)" do
          expect(ValidatingWidget.new(:name => "too short")).
            to have(1).errors_on(:name, :context => :publication)
        end

        it "passes validation with a longer name (using a validation context)" do
          expect(ValidatingWidget.new(:name => "a longer name")).
            to have(0).errors_on(:name, :context => :publication)
        end

        it "passes validation with a name (using 0)" do
          expect(ValidatingWidget.new(:name => "liquid nitrogen")).to have(0).errors_on(:name)
        end

        it "passes validation with a name (using :no)" do
          expect(ValidatingWidget.new(:name => "liquid nitrogen")).to have(:no).errors_on(:name)
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass
