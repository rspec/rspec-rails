module RSpec::Rails
  module Adapters
  end
end

require 'rspec/rails/adapters/assertion_delegator'
require 'rspec/rails/adapters/assertions'
require 'rspec/rails/adapters/minitest_counters'
require 'rspec/rails/adapters/minitest_lifecycle_adapter'
require 'rspec/rails/adapters/setup_and_teardown_adapter'
require 'rspec/rails/adapters/test_unit_assertion_adapter'
