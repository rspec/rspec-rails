module Rspec
  module Generators
    # @private
    class ActiveRecordHelperGenerator < ::Rails::Generators::Base

      desc <<DESC
Description:
    Create a spec helper file for testing ActiveRecord models in isloation.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_rails_files
        template 'spec/active_record_helper.rb'
      end
    end
  end
end
