Feature: transactional examples

  Scenario: run in transactions (default)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has none after one was created in a previous example" do
          Widget.count.should == 0
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then I should see "3 examples, 0 failures"

  Scenario: run in transactions (explicit)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      Rspec.configure do |c|
        c.use_transactional_examples = true
      end

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has none after one was created in a previous example" do
          Widget.count.should == 0
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then I should see "3 examples, 0 failures"

  Scenario: disable transactions (explicit)
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      Rspec.configure do |c|
        c.use_transactional_examples = false
      end

      describe Widget do
        it "has none to begin with" do
          Widget.count.should == 0
        end

        it "has one after adding one" do
          Widget.create
          Widget.count.should == 1
        end

        it "has one after one was created in a previous example" do
          Widget.count.should == 1
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then I should see "3 examples, 0 failures"
