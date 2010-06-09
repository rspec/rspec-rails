require 'webrat'

module RSpec::Rails
  module MailerExampleGroup
    extend ActiveSupport::Concern

    include Webrat::Matchers
    include RSpec::Matchers

    module InstanceMethods
      def read_fixture(action)
        IO.readlines(File.join(Rails.root, 'spec', 'fixtures', self.described_class.name.underscore, action))
      end
    end

    included do
      before do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries.clear
        @expected = Mail.new
        @expected.content_type ["text", "plain", { "charset" => "utf-8" }]
        @expected.mime_version = '1.0'
      end
    end

    RSpec.configure do |c|
      c.include self, :example_group => { :file_path => /\bspec\/mailers\// }
    end
  end
end
