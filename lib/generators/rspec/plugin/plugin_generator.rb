require 'generators/rspec'

module Rspec
  module Generators
    class PluginGenerator < Base
      def create_spec_files
        directory '.', 'spec'
      end
    end
  end
end
