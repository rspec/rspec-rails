module RSpec
  module Rails
    module Matchers
      module HttpResponseCodeMatchers
        HTTP_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES.merge({
          418 => "I'm A Teapot",
          426 => "Upgrade Required",
        }).freeze

        def self.clean_up_status(message)
          message.gsub(/(\s|-)/, "_").gsub('\'', '').downcase.to_sym
        end

        def self.status_as_valid_method_name(look_up_code)
          (@status_codes ||= HTTP_STATUS_CODES.inject({}) do |hash, (code, message)|
            hash[code] = clean_up_status(message)
            hash
          end.freeze)[look_up_code]
        end
        
        class HttpResponseCodeMatcher
          def initialize(expected_code)
            @expected_code = expected_code
          end

          def matches?(target)
            @target = target
            @target.code.to_i == @expected_code
          end

          def description
            "Response code should be #{@expected_code}"
          end

          def failure_message
            "Expected #{@target} to #{common_message}"
          end

          def negative_failure_message
            "Expected #{@target} to not #{common_message}"
          end
      
          def common_message
            message = "have a response code of #{@expected_code}, but got #{@target.code}"
            if @target.code.to_i == 302 || @target.code.to_i == 201
              message += " with a location of #{@target['Location'] || @target['location']}" 
            end
            message
          end
        end

        HTTP_STATUS_CODES.each do |code, status|
          define_method("be_#{status_as_valid_method_name(code)}") do
            HttpResponseCodeMatcher.new(code)
          end
        end
      end
    end
  end
end