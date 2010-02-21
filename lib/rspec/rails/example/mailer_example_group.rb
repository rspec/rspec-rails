module MailerExampleGroupBehavior

  def read_fixture(action)
    IO.readlines(File.join(Rails.root, 'spec', 'fixtures', self.described_class.name.underscore, action))
  end

  Rspec.configure do |c|
    c.include self, :example_group => { :describes => lambda {|k| k < ActionMailer::Base }}
    c.before :each, :example_group => { :describes => lambda {|k| k < ActionMailer::Base }} do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries.clear
      @expected = Mail.new
      @expected.content_type ["text", "plain", { "charset" => "utf-8" }]
      @expected.mime_version = '1.0'
    end
  end
end
