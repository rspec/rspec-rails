module RSpec::Rails::HyperShortcut
  class ShortcutElements
    def initialize(request_pair, behavior)
      @request_pair = request_pair
      @behavior = behavior
    end

    def description
      @request_pair.to_s
    end

    def it_block
      @behavior.block_to_test @request_pair.to_hash
    end
  end
end
