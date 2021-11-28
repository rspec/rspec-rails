Feature: Feature generator spec

    Scenario: Feature generator
        When I run `bundle exec rails generate rspec:feature posts`
        Then the features should pass
        Then the output should contain:
          """
                create  spec/features/posts_spec.rb
          """

    Scenario: Feature generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate rspec:feature posts`
        Then the features should pass
        Then the output should contain:
          """
                create  behaviour/features/posts_spec.rb
          """
