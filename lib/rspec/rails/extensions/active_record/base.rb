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
end
