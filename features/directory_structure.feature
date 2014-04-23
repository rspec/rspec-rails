Feature: Directory Structure

  Scenario: Specs in the `spec/controllers` directory automatically tagged as controller specs
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe WidgetsController do
        it "responds successfully" do
          get :index
          expect(response.status).to eq(200)
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
    And the output should not contain:
      """
      rspec-rails 3 will no longer automatically infer an example group's spec type
      """

  Scenario: Inferring spec type from directories is deprecated
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require File.expand_path("../../../config/environment", __FILE__)
      require 'rspec/rails'

      describe WidgetsController do
        it "responds successfully" do
          get :index
          expect(response.status).to eq(200)
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
    And the output should contain:
      """
      rspec-rails 3 will no longer automatically infer an example group's spec type
      """
