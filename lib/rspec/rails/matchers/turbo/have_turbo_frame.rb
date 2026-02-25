module RSpec
  module Rails
    module Matchers
      module Turbo
        # @private
        class HaveTurboFrame < RSpec::Matchers::BuiltIn::BaseMatcher
          def initialize(id)
            @id = id.to_s
          end

          def matches?(response)
            @response = response
            body = extract_body(response)
            @matching_elements = find_matching_elements(body)
            @matching_elements.any?
          end

          def does_not_match?(response)
            @response = response
            body = extract_body(response)
            @matching_elements = find_matching_elements(body)
            @matching_elements.empty?
          end

          def description
            "have turbo frame \"#{@id}\""
          end

          def failure_message
            "expected response to have a <turbo-frame> with id \"#{@id}\", but none was found"
          end

          def failure_message_when_negated
            "expected response not to have a <turbo-frame> with id \"#{@id}\", but it was found"
          end

        private

          def css_escape(value)
            value.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
          end

          def extract_body(response)
            if response.respond_to?(:body)
              response.body
            else
              response.to_s
            end
          end

          def find_matching_elements(body)
            return [] if body.nil? || body.empty?

            require "nokogiri"
            doc = Nokogiri::HTML::DocumentFragment.parse(body)
            doc.css("turbo-frame[id=\"#{css_escape(@id)}\"]")
          end
        end
      end
    end
  end
end
