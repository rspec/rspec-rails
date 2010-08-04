RSpec::Matchers.define :be_a_new do |model_klass|
  def with(attributes)
    @attributes = attributes.stringify_keys.to_a
    self
  end

  match do |actual|
    @unmatched_attributes = Hash.new

    @attributes.each do |key, value|
      unless actual.attributes[key].eql?(value)
        @unmatched_attributes.merge!(key => value)
      end
    end if @attributes

    @is_model_klass_new_record = actual.is_a?(model_klass) &&
                                 actual.new_record?

    @unmatched_attributes.empty? && @is_model_klass_new_record
  end

  failure_message_for_should do |actual|
    [].tap do |message|
      unless @is_model_klass_new_record
        message << "expected #{actual.inspect} to be a new #{model_klass.inspect}"
      end
      unless @unmatched_attributes.empty?
        if @unmatched_attributes.size > 1
          message << "attributes #{@unmatched_attributes.inspect} were not set on #{actual.inspect}"
        else
          message << "attribute #{@unmatched_attributes.inspect} was not set on #{actual.inspect}"
        end
      end
    end.join(' and ')
  end
end
