require 'spec_helper'

module RSpec::Rails::HyperShortcut
  describe RequestPair do
    describe "when method = :get and path = '/'" do
      before :each do
        @request_pair = RequestPair.new :get, "/"
      end

      describe 'to_hash()' do
        describe "return" do
          subject {@request_pair.to_hash}
          it {should be == {:get => '/'}}
        end
      end

      describe 'to_s()' do
        describe "integrations" do
          let(:http_method) { stub :http_method }
          before(:each){@request_pair = RequestPair.new http_method, nil}
          it "should call http_method.to_s"  do
            http_method.should_receive(:to_s).and_return(stub.as_null_object)
          end
          after(:each){@request_pair.to_s}
        end

        describe "return" do
          subject {@request_pair.to_s}
          it {should be == "GET /"}
        end
      end
    end
  end
end
