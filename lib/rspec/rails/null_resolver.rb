module ActionView #:nodoc:
  class NullResolver < PathResolver
    def query(path, exts, formats)
      handler, format = extract_handler_and_format(path, formats)
      [Template.new("RSpec-generated template", path, handler, :virtual_path => path, :format => format)]
    end
  end
end

