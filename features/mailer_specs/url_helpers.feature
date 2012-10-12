Feature: URL helpers in mailer examples

  Scenario: using URL helpers with default options
    Given a file named "config/initializers/mailer_defaults.rb" with:
      """ruby
      Rails.configuration.action_mailer.default_url_options = { :host => 'example.com' }
      """
    And a file named "spec/mailers/notifications_spec.rb" with:
      """ruby
      require 'spec_helper'

      describe Notifications do
        it 'should have access to URL helpers' do
          expect { gadgets_url }.not_to raise_error
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: using URL helpers without default options
    Given a file named "config/initializers/mailer_defaults.rb" with:
      """ruby
      # no default options
      """
    And a file named "spec/mailers/notifications_spec.rb" with:
      """ruby
      require 'spec_helper'

      describe Notifications do
        it 'should have access to URL helpers' do
          expect { gadgets_url :host => 'example.com' }.not_to raise_error
          expect { gadgets_url }.to raise_error
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass
