require 'spec_helper'

module RSpec::Rails::HyperShortcut
  describe MatcherPlaceholder do

    before :each do 
      name = :route_to
      args = [{:controller => "tests", :action => "index"}]
      @matcher_placeholder = MatcherPlaceholder.new name, args
    end


    describe "method build_matcher_in(example)" do

      describe "integrations" do
        it "should call name of matcher in example" do
          @example = stub :example
          @example.should_receive(:route_to)
                  .with(:controller => "tests", :action => "index")
          @matcher_placeholder.build_matcher_in @example
        end
      end

    end
  end
end
