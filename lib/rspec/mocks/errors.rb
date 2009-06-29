module Rspec
  module Mocks
    class MockExpectationError < Exception
    end
    
    class AmbiguousReturnError < StandardError
    end
  end
end

