Feature: System generator spec

    Scenario: System generator
        When I run `bundle exec rails generate rspec:system posts`
        Then the features should pass
        Then the output should contain:
          """
                create  spec/system/posts_spec.rb
          """

    Scenario: System generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate rspec:system posts`
        Then the features should pass
        Then the output should contain:
          """
                create  behaviour/system/posts_spec.rb
          """
