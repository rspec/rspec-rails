require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do
    it { should be_included_in_files_in('./spec/mailers/') }
    it { should be_included_in_files_in('.\\spec\\mailers\\') }
  end
end
