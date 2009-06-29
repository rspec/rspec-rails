# Require everything except the global extensions of class and object. This
# supports wrapping rspec's mocking functionality without invading every
# object in the system.

require 'rspec/mocks/methods'
require 'rspec/mocks/argument_matchers'
require 'rspec/mocks/spec_methods'
require 'rspec/mocks/proxy'
require 'rspec/mocks/mock'
require 'rspec/mocks/argument_expectation'
require 'rspec/mocks/message_expectation'
require 'rspec/mocks/order_group'
require 'rspec/mocks/errors'
require 'rspec/mocks/error_generator'
require 'rspec/mocks/space'
