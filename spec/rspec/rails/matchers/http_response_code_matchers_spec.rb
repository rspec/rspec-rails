require "spec_helper"
require "active_support/test_case"

module RSpec::Rails::Matchers
  describe 'API matchers' do
    include HttpResponseCodeMatchers

    let(:response) { ActionController::TestResponse.new }
  
    context 'status to matcher conversion' do
      it "replaces spaces with underscores" do
        HttpResponseCodeMatchers::clean_up_status("Method Not Allowed").should eq(:method_not_allowed)
      end
      
      it "downcases capital letters" do
        HttpResponseCodeMatchers::clean_up_status("IM Used").should eq(:im_used)
      end
      
      it "removes apostrophes" do
        HttpResponseCodeMatchers::clean_up_status("I'm A Teapot").should eq(:im_a_teapot)
      end
      
      it "replaces hyphens with underscores" do
        HttpResponseCodeMatchers::clean_up_status("Non-Authoritative Information").should eq(:non_authoritative_information)
      end
    end
    
    context "matching codes" do
      HttpResponseCodeMatchers::HTTP_STATUS_CODES.each do |code, status|
        it "understands if a response is of type #{status}" do
          response.stub(:code).and_return(code.to_s)
          response.should send("be_#{HttpResponseCodeMatchers.status_as_valid_method_name(code)}")
        end
    
        it "understands if a response is not of type #{status}" do
          response.stub(:code).and_return('0')
          response.should_not send("be_#{HttpResponseCodeMatchers.status_as_valid_method_name(code)}")
        end
      end
      
      context "responses where the value of the location can be important" do
        it "response of type created" do
          response.stub(:code).and_return('201')
          response.headers['Location'] = 'http://test.server'
          expect{ response.should be_ok }.to raise_error(/with a location of http:\/\/test\.server$/)
        end

        it "response of type redirect" do
          response.stub(:code).and_return('302')
          response.headers['Location'] = 'http://test.server'
          expect{ response.should be_ok }.to raise_error(/with a location of http:\/\/test\.server$/)
        end
      end
    end
  end
end