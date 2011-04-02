module RSpec::Rails
  module HyperShortcut
    module AdditionalMethods
      Matchers::RoutingMatchers::RouteHelpers::NAMES.each do |http_method|
        define_method http_method do |path|
          request_pair = RequestPair.new(http_method,path)
          SubjectPlaceholder.new(self, request_pair)
        end
      end

    private
      def method_missing(method_name,*args)
        if self.new.methods.include? method_name
          MatcherPlaceholder.new(method_name,args)
        else
          super(method_name,*args)
        end
      end
    end
  end
end

