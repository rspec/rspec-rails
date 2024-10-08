Feature: View specs infer controller's path and action

  Scenario: Infer controller path
    Given a file named "spec/views/widgets/new.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/new" , type: :view do
        it "infers the controller path" do
          expect(controller.request.path_parameters[:controller]).to eq("widgets")
          expect(controller.controller_path).to eq("widgets")
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: Infer action
    Given a file named "spec/views/widgets/new.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/new" , type: :view do
        it "infers the controller action" do
          expect(controller.request.path_parameters[:action]).to eq("new")
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: Do not infer action in a partial
    Given a file named "spec/views/widgets/_form.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/_form" , type: :view do
        it "includes a link to new" do
          expect(controller.request.path_parameters[:action]).to be_nil
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass
