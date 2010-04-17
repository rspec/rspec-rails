require 'active_support/core_ext/class/attribute_accessors'
require 'action_controller'
require 'action_dispatch'
require 'webrat'

# Preliminary documentation (more to come ....):
#
#   allow_forgery_protection is set to false
#   - you can set it to true in a before(:each) block
#     if you have a specific example that needs it, but
#     be sure to restore it to false (or supply tokens
#     to all of your example requests)

module ControllerExampleGroupBehaviour
  include ActionDispatch::Assertions
  include ActionDispatch::Integration::Runner
  include Webrat::Matchers
  include Webrat::Methods
  include Rspec::Matchers

  def self.setup(*args); end
  def self.teardown(*args); end

  include ActionController::TemplateAssertions

  def self.included(mod)
    mod.before do
      @_result = Struct.new(:add_assertion).new
      ActionController::Base.allow_forgery_protection = false
    end
  end

  def app 
    described_class.action(@_action).tap do |endpoint|
      def endpoint.routes
        Rails.application.routes
      end
    end
  end

  %w[get post put delete head].map do |method|
    eval <<-CODE
      def #{method}(*args)
        @_action = args.shift
        super '/', *args
      end
    CODE
  end

  Rspec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/controllers\// }
  end
end
