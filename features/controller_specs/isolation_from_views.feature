Feature: views are stubbed by default

  By default, controller specs stub views with a template that renders an empty
  string instead of the views in the app. This allows you specify which view
  template an action should try to render regardless of whether the template
  compiles cleanly.

  NOTE: unlike rspec-rails-1.x, the real template must exist.

  Scenario: expect template that is rendered by controller action (passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe WidgetsController, :type => :controller do
        describe "index" do
          it "renders the index template" do
            get :index
            expect(response).to render_template("index")
            expect(response.body).to eq ""
          end
          it "renders the widgets/index template" do
            get :index
            expect(response).to render_template("widgets/index")
            expect(response.body).to eq ""
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: expect template that is not rendered by controller action (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe WidgetsController, :type => :controller do
        describe "index" do
          it "renders the 'new' template" do
            get :index
            expect(response).to render_template("new")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the output should contain "1 example, 1 failure"

  Scenario: expect empty templates to render when view path is changed at runtime (passes)
    Given a file named "spec/controllers/things_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ThingsController, :type => :controller do
        describe "custom_action" do
          it "renders an empty custom_action template" do
            controller.prepend_view_path 'app/views'
            controller.append_view_path 'app/views'
            get :custom_action
            expect(response).to render_template("custom_action")
            expect(response.body).to eq ""
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: expect template to render the real template with render_views when view path is changed at runtime
    Given a file named "spec/controllers/things_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ThingsController, :type => :controller do
        render_views

        it "renders the real custom_action template" do
          controller.prepend_view_path 'app/views'
          get :custom_action
          expect(response).to render_template("custom_action")
          expect(response.body).to match(/template for a custom action/)
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: expect template that is rendered as a file(passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ApplicationController, :type => :controller do
        controller do
          def index
            render file: File.expand_path('app/views/widgets/widget.html.erb')
          end
        end
        it "renders the template" do
          get :index
          expect(response).to render_template(file: File.expand_path('app/views/widgets/widget.html.erb'))
          expect(response.body).to eq ""
        end
      end
      """
    And a file named "app/views/widgets/widget.html.erb" with:
      """
      HTML
      """
    When I run `rspec spec`
    Then the examples should all pass
