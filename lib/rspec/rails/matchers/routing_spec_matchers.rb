module RSpec::Rails::Matchers
  module RoutingSpecMatchers
    extend RSpec::Matchers::DSL

    # :call-seq:
    #   "path".should route_to(expected)  # assumes GET
    #   { :get => "path" }.should route_to(expected)
    #   { :put => "path" }.should route_to(expected)
    #
    # Delegates to <tt>assert_routing()</tt> to verify that the path-and-method
    # routes to a given set of options.  Also verifies route-generation, so
    # that the expected options generate a pathname consistent with the
    # indicated path/method.
    #
    # For negative specs, only the route recognition failure can be tested;
    # since route generation via path_to() will always generate a path as
    # requested.  Use .should_not be_routable() in this case.
    #
    # == Examples
    # { :get => '/registrations/1/edit' }.
    #   should route_to(:controller => 'registrations', :action => 'edit', :id => '1')
    # { :put => "/registrations/1" }.should
    #   route_to(:controller => 'registrations', :action => 'update', :id => 1)
    # { :post => "/registrations/" }.should
    #   route_to(:controller => 'registrations', :action => 'create')
    matcher :route_to do |route_options|
      match_unless_raises Test::Unit::AssertionFailedError do |path|
        assertion_path = { :method => path.keys.first, :path => path.values.first }
        assert_routing(assertion_path, route_options)
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end

    matcher :be_routable do
      match_unless_raises ActionController::RoutingError do |path|
        @routing_options = routes.recognize_path(
          path.values.first, :method => path.keys.first
        )
      end

      failure_message_for_should_not do |path|
        "expected #{path.inspect} not to be routable, but it routes to #{@routing_options.inspect}"
      end
    end
  end
end
