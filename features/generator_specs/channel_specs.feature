Feature: Channel generator spec

    Scenario: Channel generator
        When I run `bundle exec rails generate channel group`
        Then the features should pass
        Then the output should contain:
          """
                invoke  rspec
                create    spec/channels/group_channel_spec.rb
                create  app/channels/group_channel.rb
             identical  app/javascript/channels/index.js
             identical  app/javascript/channels/consumer.js
                create  app/javascript/channels/group_channel.js
          """

    Scenario: Channel generator with customized `default-path`
        Given a file named ".rspec" with:
          """
          --default-path behaviour
          """
        And I run `bundle exec rails generate channel group`
        Then the features should pass
        Then the output should contain:
          """
                invoke  rspec
                create    behaviour/channels/group_channel_spec.rb
                create  app/channels/group_channel.rb
             identical  app/javascript/channels/index.js
             identical  app/javascript/channels/consumer.js
                create  app/javascript/channels/group_channel.js
          """
