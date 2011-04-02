module RSpec::Rails::HyperShortcut
  class RequestPair
    def initialize(method,path)
      @method = method
      @path = path
    end

    def to_hash
      {@method => @path}
    end

    def to_s
      "#{@method.to_s.upcase} #{@path}"
    end
  end
end
