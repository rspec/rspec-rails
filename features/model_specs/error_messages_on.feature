Feature: error_messages_on

  Scenario: without validation for an attribute
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
      end

      describe ValidatingWidget do
        it "has no validation error message for non existing attribute (using error_message_on)" do
					ValidatingWidget.new.error_message_on(:foo).should be_blank
					ValidatingWidget.new.error_message_on(:foo).should be_nil
        end

        it "has no validation error message non existing attribute (using error_messages_on)" do
					ValidatingWidget.new.error_messages_on(:foo).should be_blank
					ValidatingWidget.new.error_messages_on(:foo).should be_nil
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the examples should all pass

  Scenario: with no validation errors for an attribute
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
        validates_presence_of :name
      end

      describe ValidatingWidget do
        it "has no validation error message (using error_message_on)" do
					ValidatingWidget.new(:name => 'Yo').error_message_on(:name).should be_blank
					ValidatingWidget.new(:name => 'Yo').error_message_on(:name).should be_nil
        end

        it "has no validation error message (using error_messages_on)" do
					ValidatingWidget.new(:name => 'Yo').error_messages_on(:name).should be_blank
					ValidatingWidget.new(:name => 'Yo').error_messages_on(:name).should be_nil
        end
	    end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the examples should all pass

  Scenario: with no validation errors for an attribute but other attributes fail validation
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
        validates_presence_of :name
      end

      describe ValidatingWidget do
        it "has no validation error message (using error_message_on)" do
					ValidatingWidget.new.error_message_on(:foo).should be_blank
					ValidatingWidget.new.error_message_on(:foo).should be_nil
        end

        it "has no validation error message (using error_messages_on)" do
					ValidatingWidget.new.error_messages_on(:foo).should be_blank
					ValidatingWidget.new.error_messages_on(:foo).should be_nil
        end
	    end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the examples should all pass

  Scenario: with one validation error for an attribute
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
        validates_presence_of :name, :message => 'our error'
      end

      describe ValidatingWidget do
        it "has validation error message (using error_message_on)" do
          ValidatingWidget.new.error_message_on(:name).should == 'our error'	
        end

        it "has validation error message (using error_messages_on)" do
          ValidatingWidget.new.error_messages_on(:name).should == 'our error'	
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the examples should all pass

  Scenario: with two validation errors for an attribute
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      class ValidatingWidget < ActiveRecord::Base
        set_table_name :widgets
			  validates_length_of :name, :within => 10..20, :too_long => "pick a shorter name", :too_short => "pick a longer name"
				validates_format_of :name, :with => /^[a-zA-Z]*$/, :message => "can only contain letters"
      end

      describe ValidatingWidget do
        it "has validation error message array (using error_message_on)" do
          ValidatingWidget.new(:name => '1').error_message_on(:name).should eq([ 'pick a longer name','can only contain letters'])
        end

        it "has validation error message array (using error_messages_on)" do
          ValidatingWidget.new(:name => '1').error_messages_on(:name).should eq([ 'pick a longer name','can only contain letters']) 
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the examples should all pass
