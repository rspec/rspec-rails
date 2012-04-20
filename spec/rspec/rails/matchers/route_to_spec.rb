require "spec_helper"

describe "route_to" do
  include RSpec::Rails::Matchers::RoutingMatchers
  include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers

  def assert_recognizes(*)
    # no-op
  end

  it "provides a description" do
    matcher = route_to("these" => "options")
    matcher.matches?(:get => "path")
    matcher.description.should == "route {:get=>\"path\"} to {\"these\"=>\"options\"}"
  end

  it "delegates to assert_recognizes" do
    self.should_receive(:assert_recognizes).with({ "these" => "options" }, { :method=> :get, :path=>"path" }, {})
    {:get => "path"}.should route_to("these" => "options")
  end

  context "with shortcut syntax" do
    it "routes with extra options" do
      self.should_receive(:assert_recognizes).with({ :controller => "controller", :action => "action", :extra => "options"}, { :method=> :get, :path=>"path" }, {})
      get("path").should route_to("controller#action", :extra => "options")
    end

    it "routes without extra options" do
      self.should_receive(:assert_recognizes).with(
        {:controller => "controller", :action => "action"}, 
        {:method=> :get, :path=>"path" },
        {}
      )
      get("path").should route_to("controller#action")
    end

    it "routes with one query parameter" do
      self.should_receive(:assert_recognizes).with(
        {:controller => "controller", :action => "action", :queryitem => "queryvalue"},
        {:method=> :get, :path=>"path" },
        {'queryitem' => 'queryvalue' }
      )
      get("path?queryitem=queryvalue").should route_to("controller#action", :queryitem => 'queryvalue')
    end

    it "routes with multiple query parameters" do
      self.should_receive(:assert_recognizes).with(
        {:controller => "controller", :action => "action", :queryitem => "queryvalue", :qi2 => 'qv2'},
        {:method=> :get, :path=>"path"},
        {'queryitem' => 'queryvalue', 'qi2' => 'qv2'}
      )
      get("path?queryitem=queryvalue&qi2=qv2").should route_to("controller#action", :queryitem => 'queryvalue', :qi2 => 'qv2')
    end

  end

  context "with should" do
    context "when assert_recognizes passes" do
      it "passes" do
        self.stub!(:assert_recognizes)
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to_not raise_exception
      end
    end

    context "when assert_recognizes fails with an assertion failure" do
      it "fails with message from assert_recognizes" do
        self.stub!(:assert_recognizes) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, "this message")
      end
    end

    context "when assert_recognizes fails with a routing error" do
      it "fails with message from assert_recognizes" do
        self.stub!(:assert_recognizes) do
          raise ActionController::RoutingError.new("this message")
        end
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, "this message")
      end
    end

    context "when an exception is raised" do
      it "raises that exception" do
        self.stub!(:assert_recognizes) do
          raise "oops"
        end
        expect do
          {:get => "path"}.should route_to("these" => "options")
        end.to raise_exception("oops")
      end
    end
  end

  context "with should_not" do
    context "when assert_recognizes passes" do
      it "fails with custom message" do
        self.stub!(:assert_recognizes)
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to raise_error(/expected .* not to route to .*/)
      end
    end

    context "when assert_recognizes fails with an assertion failure" do
      it "passes" do
        self.stub!(:assert_recognizes) do
          raise ActiveSupport::TestCase::Assertion.new("this message")
        end
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to_not raise_error
      end
    end

    context "when assert_recognizes fails with a routing error" do
      it "passes" do
        self.stub!(:assert_recognizes) do
          raise ActionController::RoutingError.new("this message")
        end
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to_not raise_error
      end
    end

    context "when an exception is raised" do
      it "raises that exception" do
        self.stub!(:assert_recognizes) do
          raise "oops"
        end
        expect do
          {:get => "path"}.should_not route_to("these" => "options")
        end.to raise_exception("oops")
      end
    end
  end

  it "uses failure message from assert_recognizes" do
    self.stub!(:assert_recognizes).and_raise(
      ActiveSupport::TestCase::Assertion.new("this message"))
    expect do
      {"this" => "path"}.should route_to("these" => "options")
    end.to raise_error("this message")
  end
end
