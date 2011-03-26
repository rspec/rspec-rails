require 'rspec/rails/example/routing_example_group/describe_with_request_pair_support/request_pair'

module RSpec::Rails
  module RoutingExampleGroup
    module DescribeWithRequestPairSupport
      def set_it_up(*args)
        describe_title = args.first
        if describe_title.is_a?(Hash) && ['get','post','put','delete'].include?(describe_title.keys.first.to_s.downcase)
          describe_title.instance_eval{extend RSpec::Rails::Ruby::Hash}
          describe_title.keep_first!
          request_pair = RequestPair.new :http_method => describe_title.key,
                                         :path => describe_title.value
          args[0] = request_pair.to_s
          superclass_metadata[:example_group].store(:describes, request_pair.to_hash)
        end
        super(*args)
      end
    end
  end
end

