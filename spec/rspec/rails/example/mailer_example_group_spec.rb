module RSpec::Rails
  RSpec.describe MailerExampleGroup, :with_isolated_config do

    it_behaves_like "an rspec-rails example group mixin", :mailer,
                    './spec/mailers/', '.\\spec\\mailers\\'
  end
end
