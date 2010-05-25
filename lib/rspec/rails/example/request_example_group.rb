require 'action_dispatch'
require 'webrat'

module RequestExampleGroupBehaviour
  extend ActiveSupport::Concern

  include ActionDispatch::Integration::Runner
  include RSpec::Rails::TestUnitAssertionAdapter
  include ActionDispatch::Assertions
  include Webrat::Matchers
  include Webrat::Methods
  include RSpec::Matchers

  included do
    before do
      @router = ::Rails.application.routes
    end
  end
  
  def app
    ::Rails.application
  end

  def last_response
    response
  end

  Webrat.configure do |config|
    config.mode = :rack
  end

  RSpec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/requests\// }
  end
end
