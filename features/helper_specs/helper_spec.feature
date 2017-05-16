Feature: helper spec

  Helper specs are marked by `:type => :helper` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/helpers`.

  Helper specs expose a `helper` object, which includes the helper module being
  specified, the `ApplicationHelper` module (if there is one) and all of the
  helpers built into Rails. It does not include the other helper modules in
  your app.

  To access the helper methods you're specifying, simply call them directly
  on the `helper` object, or call them directly within the example

  NOTE: helper methods defined in controllers are not included.

  Scenario: helper method that returns a value
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ApplicationHelper, :type => :helper do
        describe "#page_title" do
          it "returns the default title" do
            expect(helper.page_title).to eq("RSpec is your friend")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """ruby
      module ApplicationHelper
        def page_title
          "RSpec is your friend"
        end
      end
      """
    When I run `rspec spec/helpers/application_helper_spec.rb`
    Then the examples should all pass

  Scenario: helper method that accesses an instance variable
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ApplicationHelper, :type => :helper do
        describe "#page_title" do
          it "returns the instance variable" do
            assign(:title, "My Title")
            expect(helper.page_title).to eql("My Title")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """ruby
      module ApplicationHelper
        def page_title
          @title || nil
        end
      end
      """
    When I run `rspec spec/helpers/application_helper_spec.rb`
    Then the examples should all pass

  Scenario: application helper is included in helper object
    Given a file named "spec/helpers/widgets_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe WidgetsHelper, :type => :helper do
        describe "#widget_title" do
          it "includes the app name" do
            assign(:title, "This Widget")
            expect(helper.widget_title).to eq("The App: This Widget")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """ruby
      module ApplicationHelper
        def app_name
          "The App"
        end
      end
      """
    And a file named "app/helpers/widgets_helper.rb" with:
      """ruby
      module WidgetsHelper
        def widget_title
          "#{app_name}: #{@title}"
        end
      end
      """
    When I run `rspec spec/helpers/widgets_helper_spec.rb`
    Then the examples should all pass

  Scenario: url helpers are defined
    Given a file named "spec/helpers/widgets_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe WidgetsHelper, :type => :helper do
        describe "#link_to_widget" do
          it "links to a widget using its name" do
            widget = Widget.create!(:name => "This Widget")
            expect(helper.link_to_widget(widget)).to include("This Widget")
            expect(helper.link_to_widget(widget)).to include(widget_path(widget))
          end
        end
      end
      """
    And a file named "app/helpers/widgets_helper.rb" with:
      """ruby
      module WidgetsHelper
        def link_to_widget(widget)
          link_to(widget.name, widget_path(widget))
        end
      end
      """
    When I run `rspec spec/helpers/widgets_helper_spec.rb`
    Then the examples should all pass

  Scenario: helper methods are accessible from within example
    Given a file named "spec/helpers/user_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UserHelper, :type => :helper do
        describe "#email" do
          it "gives current user email" do
            expect(email).to eq "jon.snow@example.com"
          end
        end
      end
      """
    And a file named "app/helpers/user_helper.rb" with:
      """ruby
      module UserHelper
        def email
          "jon.snow@example.com"
        end
      end
      """
    When I run `rspec spec/helpers/user_helper_spec.rb`
    Then the examples should all pass

  Scenario: methods defined in example are visible within example
    Given a file named "spec/helpers/user_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UserHelper, :type => :helper do
        describe "#email" do
          context "when user is logged in" do
            let(:current_user) { double("user", {:email => "jon.snow@example.com"}) }

            it "gives current user email" do
              expect(email).to eq "jon.snow@example.com"
            end
          end

          context "when user isn't logged in" do
            def current_user; end

            it "gives n/a" do
              expect(email).to eq "n/a"
            end
          end

          context "when current_user isn't defined" do
            it "throws an exception" do
              expect { email }.to raise_error NameError
            end
          end
        end
      end
      """
    And a file named "app/helpers/user_helper.rb" with:
      """ruby
      module UserHelper
        def email
          current_user.nil? ? 'n/a' : current_user.email
        end
      end
      """
    When I run `rspec spec/helpers/user_helper_spec.rb`
    Then the examples should all pass

  Scenario: methods defined in example are not visible in helper
    Given a file named "spec/helpers/user_helper_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UserHelper, :type => :helper do
        describe "#email" do
          context "when current_user is defined" do
            let(:current_user) { double("user", {:email => "jon.snow@example.com"}) }
            it "throws an exception" do
              expect { helper.email }.to raise_error NameError, /undefined local variable or method `current_user'/
            end
          end
        end
      end
      """
    And a file named "app/helpers/user_helper.rb" with:
      """ruby
      module UserHelper
        def email
          current_user.email
        end
      end
      """
    When I run `rspec spec/helpers/user_helper_spec.rb`
    Then the examples should all pass
