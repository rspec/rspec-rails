Feature: Helper generator spec

  Scenario: Helper generator
    When I run `bundle exec rails generate helper posts`
    Then the features should pass
    Then the output should contain:
      """
            create  app/helpers/posts_helper.rb
            invoke  rspec
            create    spec/helpers/posts_helper_spec.rb
      """

  Scenario: Helper generator with customized `default-path`
    Given a file named ".rspec" with:
      """
      --default-path behaviour
      """
    And I run `bundle exec rails generate helper posts`
    Then the features should pass
    Then the output should contain:
      """
            create  app/helpers/posts_helper.rb
            invoke  rspec
            create    behaviour/helpers/posts_helper_spec.rb
      """
