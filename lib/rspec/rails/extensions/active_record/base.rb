module RSpec
  module Rails
    if defined?(ActiveRecord)
      module Extensions
        module ActiveRecord
          # Extension to enhance `should have` on AR Model classes
          #
          # @example
          #
          #     ModelClass.should have(:no).records
          #     ModelClass.should have(1).record
          #     ModelClass.should have(n).records
          def records
            find(:all)
          end
          alias :record :records
        end

        class ::ActiveRecord::Base
          extend RSpec::Rails::Extensions::ActiveRecord
        end
      end
    end
  end
end

module ::ActiveModel::Validations
  # Extension to enhance `should have` on AR Model instances.  Calls
  # model.valid? in order to prepare the object's errors object. 
  #
  # You can also use this to specify the content of the error messages.
  #
  # @example
  #
  #     model.should have(:no).errors_on(:attribute)
  #     model.should have(1).error_on(:attribute)
  #     model.should have(n).errors_on(:attribute)
  #
  #     model.errors_on(:attribute).should include("can't be blank")
  def errors_on(attribute)
    self.valid?
    [self.errors[attribute]].flatten.compact
  end
  alias :error_on :errors_on

  # :call-seq:
  #   model.error_message_on(:attribute).should be_blank
  #   model.error_message_on(:attribute).should == 'msg'
  #   model.error_messages_on(:attribute).should == ['msg1', 'msg2']
  #
  # Extension to enhance AR Model instances to ensure the correct validation 
  # rule executed by testing the validation message itself, instead of the 
  # attribute's error count.
  #
  # Equivalent to, yet sounds more natural, than:
  #   model.errors[:attribute].should include('msg') 
  #
  # Reasoning: If there are two or more validations for :attribute, each
  # should be tested.  Simply calling model.should have(1).error_on(:attribute)
  # could yield false positives if the wrong validation fires.  It's better to 
  # check that the proper validation was triggered via the validation message 
  #
  # For zero or one error message, the AR infused array is dropped, making the
  # test should more natural (e.g. == 'msg' instead of eq(['msg'])
  #
  # Calls model.valid? in order to prepare the object's errors
  # object.
  def error_messages_on(attribute)
    return nil if self.valid?                                               # Model valid
    return nil if self.errors[attribute].empty?                             # Model invalid, this attribute is valid
    return self.errors[attribute][0] if self.errors[attribute].length == 1  # Attribute invalid, one error msg
    self.errors[attribute]                                                  # Attribute invalid, two+ error msg
  end
  alias :error_message_on :error_messages_on
end
