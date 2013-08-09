module RSpec::Rails::Adapters
  # @api private
  module MinitestCounters
    # @api private
    def assertions
      @assertions ||= 0
    end

    # @api private
    def assertions=(assertions)
      @assertions = assertions
    end
  end
end
