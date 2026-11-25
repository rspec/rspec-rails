require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class AuthenticationGenerator < Base
      class_option :request_specs, type: :boolean, default: true, desc: 'Generate request specs'

      def initialize(args, *options)
        args.replace(['User'])
        super
      end

      def create_user_spec
        template 'user_spec.rb', target_path('models', 'user_spec.rb')
      end

      hook_for :fixture_replacement

      def create_fixture_file
        return if options[:fixture_replacement]

        template 'users.yml', target_path('fixtures', 'users.yml')
      end

      def create_session_request_spec
        return unless options[:request_specs]

        template 'session_spec.rb', target_path('requests', 'sessions_spec.rb')
      end

      def create_password_request_spec
        return unless options[:request_specs]

        template 'password_spec.rb', target_path('requests', 'passwords_spec.rb')
      end

      def create_authentication_support
        template 'authentication_support.rb', target_path('support', 'authentication_support.rb')
      end

      def configure_authentication_support
        rails_helper_path = File.join(destination_root, 'spec', 'rails_helper.rb')
        return unless File.exist?(rails_helper_path)

        # Uncomment the support files loading line if it's commented out
        uncomment_lines rails_helper_path, /Rails\.root\.glob\('spec\/support\/\*\*\/\*\.rb'\)\.sort_by\(&:to_s\)\.each \{ \|f\| require f \}/

        include_statement = "  # Include authentication support module for request specs\n  config.include AuthenticationSupport, type: :request\n"

        # Insert the include statement before the final 'end' of the RSpec.configure block
        inject_into_file rails_helper_path, include_statement, before: /^end\s*$/
      end
    end
  end
end
