module RSpec::Rails::Matchers
  module RoutingMatchers
    extend RSpec::Matchers::DSL

    matcher :route_to do |*expected|
      expected_options = expected[1] || {}
      if Hash === expected[0]
        expected_options.merge!(expected[0])
      else
        controller, action = expected[0].split('#')
        expected_options.merge!(:controller => controller, :action => action)
      end

      match_unless_raises ActiveSupport::TestCase::Assertion do |verb_to_path_map|
        path, query = *verb_to_path_map.values.first.split('?')
        assert_recognizes(
          expected_options,
          {:method => verb_to_path_map.keys.first, :path => path},
          Rack::Utils::parse_query(query)
        )
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

    module RouteHelpers

      %w(get post put delete options head).each do |method|
        define_method method do |path|
          { method.to_sym => path }
        end
      end

    end
  end
end
