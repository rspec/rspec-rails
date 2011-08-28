module RSpec::Rails::Matchers
  module RoutingMatchers
    extend RSpec::Matchers::DSL

    matcher :route_to do |*route_options|
      match_unless_raises ActiveSupport::TestCase::Assertion do |path|
        assertion_path = { :method => path.keys.first, :path => path.values.first }
        assertion_query_params, assertion_path[:path] = QueryHelpers::extract_query_params(assertion_path[:path])

        path, options = *route_options

        if path.is_a?(String)
          controller, action = path.split("#")
          options ||= {}
          options.merge!(:controller => controller, :action => action)
        else
          options = path
        end

        assert_recognizes(options, assertion_path, assertion_query_params)
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

    class QueryHelpers
      def self.extract_query_params(path)
        params = {}
        cleaned_path = path
        if not path.index('?').nil?
          cleaned_path, params_string = path.split('?')
          params_string.split('&').each do |kvp|
            key, value = kvp.split('=')
            params[key.to_sym] = value
          end
        end
        [params, cleaned_path]
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
