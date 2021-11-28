Feature: Controller generator spec

    Scenario: Controller generator
        When I run `bundle exec rails generate controller posts`
        Then the features should pass
        Then the output should contain:
          """
                create  app/controllers/posts_controller.rb
                invoke  erb
                create    app/views/posts
                invoke  rspec
                create    spec/requests/posts_spec.rb
                invoke  helper
                create    app/helpers/posts_helper.rb
                invoke    rspec
                create      spec/helpers/posts_helper_spec.rb
                invoke  assets
                invoke    css
                create      app/assets/stylesheets/posts.css
          """

    Scenario: Controller generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate controller posts`
        Then the features should pass
        Then the output should contain:
          """
                create  app/controllers/posts_controller.rb
                invoke  erb
                create    app/views/posts
                invoke  rspec
                create    behaviour/requests/posts_spec.rb
                invoke  helper
                create    app/helpers/posts_helper.rb
                invoke    rspec
                create      behaviour/helpers/posts_helper_spec.rb
                invoke  assets
                invoke    css
                create      app/assets/stylesheets/posts.css
          """
