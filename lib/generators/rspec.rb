require 'rails/generators/named_base'

# Weirdly named generators namespace (should be `RSpec`) for compatability with
# rails loading.
module Rspec
  # @private
  module Generators
    # @private
    class Base < ::Rails::Generators::NamedBase
      def self.source_root
        @_rspec_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'rspec', generator_name, 'templates'))
      end

      if ::Rails::VERSION::STRING < '3.1'
        def module_namespacing
          yield if block_given?
        end
      end
    end
  end
end

# @private
module Rails
  module Generators
    # @private
    class GeneratedAttribute
      def input_type
        @input_type ||= if type == :text
          "textarea"
        else
          "input"
        end
      end
    end
  end
end
