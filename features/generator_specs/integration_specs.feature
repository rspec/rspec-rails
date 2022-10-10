Feature: Integration generator spec

    Scenario: Integration generator
        When I run `bundle exec rails generate rspec:integration posts`
        Then the features should pass
        Then the output should contain:
          """
                create  spec/requests/posts_spec.rb
          """

    Scenario: Integration generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate rspec:integration posts`
        Then the features should pass
        Then the output should contain:
          """
                create  behaviour/requests/posts_spec.rb
          """
