module RSpec::Rails
  RSpec.describe MailerExampleGroup, :with_isolated_config do

    it_behaves_like "an rspec-rails example group mixin", :mailer,
                    './spec/mailers/', '.\\spec\\mailers\\'

    it "applies `config.action_mailer.default_url_options` without mutating a frozen hash" do
      original = ::Rails.configuration.action_mailer.default_url_options
      ::Rails.configuration.action_mailer.default_url_options = { host: "example.org" }

      group = RSpec::Core::ExampleGroup.describe do
        include ::Rails.application.routes.url_helpers
        self.default_url_options = {}.freeze
        include MailerExampleGroup
      end

      expect(group.default_url_options).to include(host: "example.org")
    ensure
      ::Rails.configuration.action_mailer.default_url_options = original
    end
  end
end
