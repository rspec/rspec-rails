if ::Rails::VERSION::STRING >= '4.1.0'
  gem 'minitest'
  require 'minitest/assertions'
else
  require 'test/unit/assertions'
end


module RSpec::Rails::Adapters
  module Assertions
    if ::Rails::VERSION::STRING >= '4.1.0'
      include Minitest::Assertions
    else
      include Test::Unit::Assertions
    end
  end
end
