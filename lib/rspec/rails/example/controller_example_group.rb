require 'active_support/core_ext/class/attribute_accessors'
require 'action_controller'
require 'action_dispatch'
require 'webrat'
require 'test/unit/assertions'

module Rspec::Rails::ActiveSupportConcernAdapter
  def setup(*methods)
    methods.each {|method| before { send method } }
  end

  def teardown(*methods)
    methods.each {|method| after { send method } }
  end
end

module ControllerExampleGroupBehaviour
  include Test::Unit::Assertions
  include Webrat::Matchers
  include Webrat::Methods
  include Rspec::Matchers

  def self.included(mod)
    mod.extend   Rspec::Rails::ActiveSupportConcernAdapter
    mod.__send__ :include, ActionController::TestCase::Behavior

    def mod.controller_class
      describes
    end

    mod.before do
      @routes = Rails.application.routes
      @_result = Struct.new(:add_assertion).new
      ActionController::Base.allow_forgery_protection = false
    end
  end
end

Rspec.configure do |c|
  c.include ControllerExampleGroupBehaviour, :example_group => {
    :describes => lambda {|described| described < ActionController::Base }
  }
end
