require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do
    module ::Rails; end
    before do
      allow(Rails).to receive_message_chain(:application, :routes, :url_helpers).and_return(Rails)
      allow(Rails).to receive_message_chain(:configuration, :action_mailer, :default_url_options).and_return({})
    end

    # On 1.9.2, we're getting travis failures from warnings being emitted by these specs
    # only on 1.9.2 (and only on travis; can't repro locally). The warning is:
    # /home/travis/.rvm/rubies/ruby-1.9.2-p320/lib/ruby/1.9.1/net/smtp.rb:584: warning: previous definition of tlsconnect was here
    # For now, we're just going to silence the warning.
    around { |ex| with_isolated_stderr(&ex) } if RUBY_VERSION == '1.9.2'

    it_behaves_like "an rspec-rails example group mixin", :mailer,
      './spec/mailers/', '.\\spec\\mailers\\'
  end
end
