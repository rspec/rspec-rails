require 'active_support/core_ext/class/attribute_accessors'
require 'action_controller'
require 'action_dispatch'
require 'webrat'

# BEGIN PATCH
#
# The following monkey patches to rails can be removed if/when
# https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4433
# is resolved.
require 'active_support/notifications/fanout'
class ActiveSupport::Notifications::Fanout
  def unsubscribe(subscriber_or_name)
    @listeners_for.clear
    @subscribers.reject! do |s|
      s.instance_eval do
        case subscriber_or_name
        when String
          @pattern && @pattern =~ subscriber_or_name
        when self
          true
        end
      end
    end
  end
end

require 'action_controller/test_case'
module ActionController::TemplateAssertions
  def teardown_subscriptions
    ActiveSupport::Notifications.unsubscribe("action_view.render_template")
    ActiveSupport::Notifications.unsubscribe("action_view.render_template!")
  end
end
# END PATCH

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

  module ActiveSupportConcernAdapter
    def setup(*methods)
      methods.each {|method| before { send method } }
    end

    def teardown(*methods)
      methods.each {|method| after { send method } }
    end
  end

  def self.included(mod)
    mod.extend ActiveSupportConcernAdapter

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
end

Rspec.configure do |c|
  [ControllerExampleGroupBehaviour, ActionController::TemplateAssertions].each do |mod|
    c.include mod, :example_group => { :file_path => /\bspec\/controllers\// }
  end
end
