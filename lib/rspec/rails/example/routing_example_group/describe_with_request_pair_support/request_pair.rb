module RSpec::Rails
  module RoutingExampleGroup
    module DescribeWithRequestPairSupport
      class RequestPair
        def initialize(args={})
          @method = args[:http_method]
          @path = args[:path]
        end

        def to_hash
          {@method => @path}
        end

        def to_s
          "#{@method.to_s.upcase} #{@path}"
        end
      end
    end
  end
end

