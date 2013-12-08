require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do
    module ::Rails; end
    before do
      Rails.stub_chain(:application, :routes, :url_helpers).and_return(Rails)
      Rails.stub_chain(:configuration, :action_mailer, :default_url_options).and_return({})
    end

    it { is_expected.to be_included_in_files_in('./spec/mailers/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\mailers\\') }

    it "adds :type => :mailer to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include MailerExampleGroup
      end
      expect(group.metadata[:type]).to eq(:mailer)
    end
  end
end
