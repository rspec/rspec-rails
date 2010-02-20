module Rspec # :nodoc:
  module Rails # :nodoc:
    module Version # :nodoc:
      STRING = File.read(File.expand_path('../../../../VERSION', __FILE__))
    end
  end
end
