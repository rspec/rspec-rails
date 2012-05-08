require 'spec_helper'

module RSpec::Rails::RoutingExampleGroup
  module DescribeWithRequestPairSupport
    describe RequestPair do
      before :each do
        @request_pair = RequestPair.new :http_method => :get,
                                        :path => "/"
      end

      it 'should became a hash' do
        @request_pair.to_hash.should be == {:get => "/"}
      end

      it 'should became a string' do
        @request_pair.to_s.should be == "GET /"
      end
    end
  end
end
