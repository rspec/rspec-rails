require 'action_controller'
require 'action_controller/test_case'

module ActionController
  # This has been merged to rails HEAD after the 3.0.0.beta.3 release (see
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4433).
  # Once 3.0.0.rc.1 comes out, we can remove it.
  module TemplateAssertions
    def teardown_subscriptions
      # rails-3.0.0.beta.3
      ActiveSupport::Notifications.unsubscribe("action_view.render_template")
      ActiveSupport::Notifications.unsubscribe("action_view.render_template!")

      # as of 731d4392e478ff5526b595074d9caa999da8bd0c
      ActiveSupport::Notifications.unsubscribe("render_template.action_view")
      ActiveSupport::Notifications.unsubscribe("!render_template.action_view")
    end
  end

  # This has been merged to rails HEAD after the 3.0.0.beta.3 release (see
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4474).
  # Once 3.0.0.rc.1 comes out, we can remove it.
  unless defined?(ActionController::TestCase::Behavior)
    class TestCase < ActiveSupport::TestCase
      module Behavior
        extend ActiveSupport::Concern
        include ActionDispatch::TestProcess

        attr_reader :response, :request

        module ClassMethods

          # Sets the controller class name. Useful if the name can't be inferred from test class.
          # Expects +controller_class+ as a constant. Example: <tt>tests WidgetController</tt>.
          def tests(controller_class)
            self.controller_class = controller_class
          end
          
          def controller_class=(new_class)
            prepare_controller_class(new_class) if new_class
            write_inheritable_attribute(:controller_class, new_class)
          end

          def controller_class
            if current_controller_class = read_inheritable_attribute(:controller_class)
              current_controller_class
            else
              self.controller_class = determine_default_controller_class(name)
            end
          end

          def determine_default_controller_class(name)
            name.sub(/Test$/, '').constantize
          rescue NameError
            nil
          end

          def prepare_controller_class(new_class)
            new_class.send :include, ActionController::TestCase::RaiseActionExceptions
          end

        end

        # Executes a request simulating GET HTTP method and set/volley the response
        def get(action, parameters = nil, session = nil, flash = nil)
          process(action, parameters, session, flash, "GET")
        end

        # Executes a request simulating POST HTTP method and set/volley the response
        def post(action, parameters = nil, session = nil, flash = nil)
          process(action, parameters, session, flash, "POST")
        end

        # Executes a request simulating PUT HTTP method and set/volley the response
        def put(action, parameters = nil, session = nil, flash = nil)
          process(action, parameters, session, flash, "PUT")
        end

        # Executes a request simulating DELETE HTTP method and set/volley the response
        def delete(action, parameters = nil, session = nil, flash = nil)
          process(action, parameters, session, flash, "DELETE")
        end

        # Executes a request simulating HEAD HTTP method and set/volley the response
        def head(action, parameters = nil, session = nil, flash = nil)
          process(action, parameters, session, flash, "HEAD")
        end

        def xml_http_request(request_method, action, parameters = nil, session = nil, flash = nil)
          @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
          @request.env['HTTP_ACCEPT'] ||=  [Mime::JS, Mime::HTML, Mime::XML, 'text/xml', Mime::ALL].join(', ')
          returning __send__(request_method, action, parameters, session, flash) do
            @request.env.delete 'HTTP_X_REQUESTED_WITH'
            @request.env.delete 'HTTP_ACCEPT'
          end
        end
        alias xhr :xml_http_request

        def process(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
          # Sanity check for required instance variables so we can give an
          # understandable error message.
          %w(@routes @controller @request @response).each do |iv_name|
            if !(instance_variable_names.include?(iv_name) || instance_variable_names.include?(iv_name.to_sym)) || instance_variable_get(iv_name).nil?
              raise "#{iv_name} is nil: make sure you set it in your test's setup method."
            end
          end

          @request.recycle!
          @response.recycle!
          @controller.response_body = nil
          @controller.formats = nil
          @controller.params = nil

          @html_document = nil
          @request.env['REQUEST_METHOD'] = http_method

          parameters ||= {}
          @request.assign_parameters(@routes, @controller.class.name.underscore.sub(/_controller$/, ''), action.to_s, parameters)

          @request.session = ActionController::TestSession.new(session) unless session.nil?
          @request.session["flash"] = @request.flash.update(flash || {})
          @request.session["flash"].sweep

          @controller.request = @request
          @controller.params.merge!(parameters)
          build_request_uri(action, parameters)
          Base.class_eval { include Testing }
          @controller.process_with_new_base_test(@request, @response)
          @request.session.delete('flash') if @request.session['flash'].blank?
          @response
        end

        def setup_controller_request_and_response
          @request = TestRequest.new
          @response = TestResponse.new

          if klass = self.class.controller_class
            @controller ||= klass.new rescue nil
          end

          @request.env.delete('PATH_INFO')

          if @controller
            @controller.request = @request
            @controller.params = {}
          end
        end

        # Cause the action to be rescued according to the regular rules for rescue_action when the visitor is not local
        def rescue_action_in_public!
          @request.remote_addr = '208.77.188.166' # example.com
        end

        included do
          include ActionController::TemplateAssertions
          include ActionDispatch::Assertions
          setup :setup_controller_request_and_response
        end

      private

        def build_request_uri(action, parameters)
          unless @request.env["PATH_INFO"]
            options = @controller.__send__(:url_options).merge(parameters)
            options.update(
              :only_path => true,
              :action => action,
              :relative_url_root => nil,
              :_path_segments => @request.symbolized_path_parameters)

            url, query_string = @routes.url_for(options).split("?", 2)

            @request.env["SCRIPT_NAME"] = @controller.config.relative_url_root
            @request.env["PATH_INFO"] = url
            @request.env["QUERY_STRING"] = query_string || ""
          end
        end
      end

      # When the request.remote_addr remains the default for testing, which is 0.0.0.0, the exception is simply raised inline
      # (bystepping the regular exception handling from rescue_action). If the request.remote_addr is anything else, the regular
      # rescue_action process takes place. This means you can test your rescue_action code by setting remote_addr to something else
      # than 0.0.0.0.
      #
      # The exception is stored in the exception accessor for further inspection.
      module RaiseActionExceptions
        def self.included(base)
          base.class_eval do
            attr_accessor :exception
            protected :exception, :exception=
          end
        end

        protected
          def rescue_action_without_handler(e)
            self.exception = e

            if request.remote_addr == "0.0.0.0"
              raise(e)
            else
              super(e)
            end
          end
      end
    end
  end
end
