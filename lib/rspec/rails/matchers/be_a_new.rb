module RSpec::Matchers
  class BeANew
    include BaseMatcher

    def matches?(actual)
      super
      actual.is_a?(expected) && actual.new_record? && attributes_match?(actual)
    end

    def with(expected_attributes)
      attributes.merge!(expected_attributes)
      self
    end

    def failure_message_for_should
      [].tap do |message|
        unless actual.is_a?(expected) && actual.new_record?
          message << "expected #{actual.inspect} to be a new #{expected.inspect}"
        end
        unless attributes_match?(actual)
          if unmatched_attributes.size > 1
            message << "attributes #{unmatched_attributes.inspect} were not set on #{actual.inspect}"
          else
            message << "attribute #{unmatched_attributes.inspect} was not set on #{actual.inspect}"
          end
        end
      end.join(' and ')
    end

    def attributes
      @attributes ||= {}
    end

    def attributes_match?(actual)
      attributes.stringify_keys.all? do |key, value|
        actual.attributes[key].eql?(value)
      end
    end

    def unmatched_attributes
      attributes.stringify_keys.reject do |key, value|
        actual.attributes[key].eql?(value)
      end
    end

  end

  def be_a_new(model_klass)
    BeANew.new(model_klass)
  end
end
