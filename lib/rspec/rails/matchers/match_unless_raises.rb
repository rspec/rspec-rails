module RSpec::Rails::Matchers
  module MatchUnlessRaises
    # @api private
    attr_accessor :rescued_exception

    # @api private
    def match_unless_raises(exception)
      # TODO - move this to rspec expectations
      begin
        yield
        true
      rescue exception => e
        self.rescued_exception = e
        false
      end
    end
  end
end
