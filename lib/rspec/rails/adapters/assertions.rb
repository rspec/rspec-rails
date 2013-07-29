module RSpec::Rails::Adapters
  module Assertions
    if ::Rails::VERSION::STRING >= '4.1.0'
      gem 'minitest'
      require 'minitest/assertions'
      include Minitest::Assertions
    else
      require 'test/unit/assertions'
      include Test::Unit::Assertions
    end
  end
end
