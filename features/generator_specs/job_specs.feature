Feature: Job generator spec

  Scenario: Job generator
    When I run `bundle exec rails generate job user`
    Then the features should pass
    Then the output should contain:
      """
            invoke  rspec
            create    spec/jobs/user_job_spec.rb
            create  app/jobs/user_job.rb
      """

  Scenario: Job generator with customized `default-path`
    Given a file named ".rspec" with:
      """
      --default-path behaviour
      """
    And I run `bundle exec rails generate job user`
    Then the features should pass
    Then the output should contain:
      """
            invoke  rspec
            create    behaviour/jobs/user_job_spec.rb
            create  app/jobs/user_job.rb
      """
