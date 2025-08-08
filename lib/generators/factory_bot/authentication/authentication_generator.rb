require 'generators/factory_bot'
require 'factory_bot_rails'

module FactoryBot
  module Generators
    class AuthenticationGenerator < Rails::Generators::Base
      # Use the Source_root Setter correctly
      def self.source_root
        File.expand_path('templates', __dir__)
      end

      def create_fixture_file
        # Detects whether it is RSPEC or minitest
        factories_dir =
          if Dir.exist?(Rails.root.join('spec'))
            'spec/factories'
          else
            'test/factories'
          end

        template "users.rb", "#{factories_dir}/users.rb"
      end
    end
  end
end
