module RSpec::Rails
  module Ruby
    module Hash
      def key
        self.keys.first
      end

      def value
        self.values.first
      end

      def keep_first!
        pair = self.first
        self.replace(pair.first => pair.last)
      end
    end
  end
end
