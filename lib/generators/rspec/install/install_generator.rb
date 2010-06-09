module Rspec
  module Generators
    class InstallGenerator < Rails::Generators::Base

      desc <<DESC
Description:
    Copy rspec files to your application.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_dot_rspec
        template '.rspec'
      end

      def copy_spec_files
        directory 'spec'
      end

      def copy_lib_files
        directory 'lib'
      end

      def copy_initializer_files
        inside "config" do
          empty_directory "initializers", :verbose => false

          inside "initializers" do
            template "rspec_generator.rb.tt", "rspec_generator.rb"
          end
        end
      end

      def copy_autotest_files
        directory 'autotest'
      end

      def app_name
        Rails.application.class.name
      end

    end
  end
end
