## Extends rails-mocks to allow verifying-doubles to recognise some standard
# dynamic rails methods that otherwise wouldn't be accepted
#
# The first of these is "store_accessor" - used for (de)serialising a column
# in the db.
module RailsifiedMethodReference
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        # re-alias the method that checks for visible method on an instance
        alias_method_chain :instance_method_visibility_for, :rails_extensions
        # also re-alias the method that the other modules call - so we also have
        # to redefine it to our new version
        alias :method_defined_at_any_visibility? :instance_method_visibility_for_with_rails_extensions
      end
    end
  end

  module ClassMethods
    def instance_method_visibility_for_with_rails_extensions(klass, method_name)
      # "store_accessor" columns count as valid methods
      if klass.respond_to?(:stored_attributes) && klass.stored_attributes
        # calling function expects a visibility-level
        return :public if klass.stored_attributes.has_key?(method_name)
      end

      instance_method_visibility_for_without_rails_extensions(klass, method_name)
    end
  end
end

RSpec::Mocks::MethodReference.send :include, RailsifiedMethodReference
