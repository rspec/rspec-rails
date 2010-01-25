module Rspec # :nodoc:
  module Rails # :nodoc:
    module Version # :nodoc:
      unless defined?(MAJOR)
        MAJOR  = 2
        MINOR  = 0
        TINY   = 0
        PRE    = 'a3'

        STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

        SUMMARY = "rspec-core " + STRING
      end
    end
  end
end
