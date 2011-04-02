module RSpec::Rails::HyperShortcut
  class MatcherPlaceholder
    def initialize(name,args)
      @name = name
      @args = args
    end

    def build_matcher_in(example)
      example.send(@name,*@args)
    end
  end
end
