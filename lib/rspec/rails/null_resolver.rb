module Rspec
  module Rails
    class NullResolver < ActionView::PathResolver
      def query(path, exts, formats)
        handler, format = extract_handler_and_format(path, formats)
        [ActionView::Template.new("RSpec-generated template", path, handler, :virtual_path => path, :format => format)]
      end
    end
  end
end
