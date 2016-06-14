require 'rspec/core/warnings'
require 'rspec/expectations'
require 'rspec/rails/feature_check'

module RSpec
  module Rails
    # @api public
    # Container module for Rails specific matchers that are not generally
    # included.
    module ResponseMatchers
    end
  end
end

require 'rspec/rails/response_matchers/have_rendered'
require 'rspec/rails/response_matchers/redirect_to'
require 'rspec/rails/response_matchers/routing_matchers'
require 'rspec/rails/response_matchers/have_http_status'
