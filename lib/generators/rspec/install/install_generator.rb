require "rspec/support"
require "rspec/core"
RSpec::Support.require_rspec_core "project_initializer"

module Rspec
  module Generators
    # @private
    class InstallGenerator < ::Rails::Generators::Base

      desc <<DESC
Description:
    Copy rspec files to your application.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_spec_files
        Dir.mktmpdir do |dir|
          generate_rspec_init dir
          template File.join(dir, '.rspec'), '.rspec'
          directory File.join(dir, 'spec'), 'spec'
        end
      end

      def copy_rails_files
        template 'spec/rails_helper.rb'
      end

    private

      def generate_rspec_init(tmpdir)
        initializer = ::RSpec::Core::ProjectInitializer.new(
          :destination => tmpdir,
          :report_stream => StringIO.new
        )
        initializer.run
        gsub_file File.join(tmpdir, 'spec', 'spec_helper.rb'),
                  'rspec --init',
                  'rails generate rspec:install',
                  :verbose => false
      end
    end
  end
end
