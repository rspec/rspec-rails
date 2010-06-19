module RSpec::Rails
  module Matchers
  end
end

begin
  require 'test/unit/assertionfailederror'
rescue LoadError
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
end

begin
  require "action_controller"
rescue LoadError
end

require 'rspec/rails/matchers/render_template'
require 'rspec/rails/matchers/redirect_to'
require 'rspec/rails/matchers/routing_spec_matchers'
require 'rspec/rails/matchers/model_matchers'
require 'rspec/rails/matchers/matcher_extensions'
