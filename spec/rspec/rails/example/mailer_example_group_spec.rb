require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do

    module ::Rails; end
    before do
      Rails.stub_chain(:application, :routes, :url_helpers).and_return(Rails)
      Rails.stub_chain(:configuration, :action_mailer, :default_url_options).and_return({})
    end

    it { should be_included_in_files_in('./spec/mailers/') }
    it { should be_included_in_files_in('.\\spec\\mailers\\') }
  end
end
