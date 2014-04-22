require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do
    module ::Rails; end
    before do
      allow(Rails).to receive_message_chain(:application, :routes, :url_helpers).and_return(Rails)
      allow(Rails).to receive_message_chain(:configuration, :action_mailer, :default_url_options).and_return({})
    end

    it_behaves_like "an rspec-rails example group mixin", :mailer,
      './spec/mailers/', '.\\spec\\mailers\\'

    it "adds :type => :mailer to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include MailerExampleGroup
      end
      expect(group.metadata[:type]).to eq(:mailer)
    end
  end
end
