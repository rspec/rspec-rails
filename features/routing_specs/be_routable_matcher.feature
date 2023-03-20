Feature: `be_routable` matcher

  The `be_routable` matcher is best used with `should_not` to specify that a
  given route should not be routable. It is available in routing specs (in
  spec/routing) and controller specs (in spec/controllers).

  Scenario: Specify routeable route should not be routable (fails)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "routes for Widgets", type: :routing do
        it "does not route to widgets" do
          expect(:get => "/widgets").not_to be_routable
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the output should contain "1 example, 1 failure"

  Scenario: Specify non-routeable route should not be routable (passes)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "routes for Widgets", type: :routing do
        it "does not route to widgets/foo/bar" do
          expect(:get => "/widgets/foo/bar").not_to be_routable
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the examples should all pass

  Scenario: Specify routeable route should be routable (passes)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "routes for Widgets", type: :routing do
        it "routes to /widgets" do
          expect(:get => "/widgets").to be_routable
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the examples should all pass

  Scenario: Specify non-routeable route should be routable (fails)
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "routes for Widgets", type: :routing do
        it "routes to widgets/foo/bar" do
          expect(:get => "/widgets/foo/bar").to be_routable
        end
      end
      """

    When I run `rspec spec/routing/widgets_routing_spec.rb`
    Then the output should contain "1 example, 1 failure"

  Scenario: Use `be_routable` in a controller spec
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe WidgetsController, type: :controller do
        it "routes to /widgets" do
          expect(:get => "/widgets").to be_routable
        end
      end
      """

    When I run `rspec spec/controllers/widgets_controller_spec.rb`
    Then the examples should all pass
