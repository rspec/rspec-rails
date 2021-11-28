Feature: View generator spec

    Scenario: View generator
        When I run `bundle exec rails generate rspec:view posts index`
        Then the features should pass
        Then the output should contain:
          """
                create  spec/views/posts
                create  spec/views/posts/index.html.erb_spec.rb
          """

    Scenario: View generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate rspec:view posts index`
        Then the features should pass
        Then the output should contain:
          """
                create  behaviour/views/posts
                create  behaviour/views/posts/index.html.erb_spec.rb
          """
