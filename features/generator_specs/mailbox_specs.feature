Feature: Mailbox generator spec

  Scenario: Mailbox generator
    When I run `bundle exec rails generate mailbox forwards`
    Then the features should pass
    Then the output should contain:
      """
            create  app/mailboxes/forwards_mailbox.rb
            invoke  rspec
            create    spec/mailboxes/forwards_mailbox_spec.rb
      """

  Scenario: Mailbox generator with customized `default-path`
    Given a file named ".rspec" with:
      """
      --default-path behaviour
      """
    And I run `bundle exec rails generate mailbox forwards`
    Then the features should pass
    Then the output should contain:
      """
            create  app/mailboxes/forwards_mailbox.rb
            invoke  rspec
            create    behaviour/mailboxes/forwards_mailbox_spec.rb
      """
