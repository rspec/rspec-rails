Feature: use of capybara in controller specs

  In RSpec 2.x, capybara's DSL was automatically available in controller
  specs. In RSpec 3.x, capybara is no longer available in controller specs
  automatically.

  To continue using capybara's DSL in controller specs, include
  `Capybara::DSL` explicitly.

  Scenario: Capybara::DSL methods are available, but raise deprecation warnings
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe WidgetsController do
        describe "GET index" do
          it "says 'Listing widgets'" do
            expect(RSpec).to receive(:deprecate)
            visit "/widgets"
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: include Capybara::DSL methods explicitly
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe WidgetsController do
        include Capybara::DSL

        describe "GET index" do
          it "says 'Listing widgets'" do
            expect(RSpec).not_to receive(:deprecate)
            visit "/widgets"
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass
