module RSpec
  module Rails

    class IllegalDataAccessException < StandardError; end

    module Mocks

      module InstanceMethods
        def valid?
          true
        end

        def as_new_record
          self.stub(:id) { nil }
          self
        end

        def new_record?
          !persisted?
        end

        def persisted?
          !!id
        end

        def destroy
          self.stub(:id) { nil }
        end
      end

      # Creates a mock object instance for a +string_or_model_class+ with
      # common methods stubbed out. Additional methods may be easily stubbed
      # (via add_stubs) if +stubs+ is passed.
      #
      # +model_class+ can be any of:
      #
      #   * A String representing a Class that does not exist
      #   * A String representing a Class that extends ActiveModel::Naming
      #   * A Class that extends ActiveModel::Naming
      def mock_model(string_or_model_class, options_and_stubs = {})
        if String === string_or_model_class
          if Object.const_defined?(string_or_model_class)
            model_class = Object.const_get(string_or_model_class)
          else
            model_class = Object.const_set(string_or_model_class, Class.new do
              extend ActiveModel::Naming
            end)
          end
        else
          model_class = string_or_model_class
        end

        unless model_class.kind_of? ActiveModel::Naming
          raise ArgumentError.new <<-EOM
The mock_model method can only accept as its first argument:
  * A String representing a Class that does not exist
  * A String representing a Class that extends ActiveModel::Naming
  * A Class that extends ActiveModel::Naming

It received #{model_class.inspect}
EOM
        end

        id = options_and_stubs.has_key?(:id) ? options_and_stubs[:id] : next_id
        options_and_stubs = options_and_stubs.reverse_merge({
          :id => id,
          :destroyed? => false,
          :marked_for_destruction? => false
        })
        derived_name = "#{model_class.name}_#{id}"
        m = mock(derived_name, options_and_stubs)
        m.extend InstanceMethods
        m.extend ActiveModel::Conversion
        errors = ActiveModel::Errors.new(m)
        [:save, :update_attributes].each do |key|
          if options_and_stubs[key] == false
            errors.stub(:empty?) { false }
          end
        end
        m.stub(:errors) { errors }
        m.__send__(:__mock_proxy).instance_eval(<<-CODE, __FILE__, __LINE__)
          def @object.is_a?(other)
            #{model_class}.ancestors.include?(other)
          end
          def @object.kind_of?(other)
            #{model_class}.ancestors.include?(other)
          end
          def @object.instance_of?(other)
            other == #{model_class}
          end
          def @object.respond_to?(method_name)
            #{model_class}.respond_to?(:column_names) && #{model_class}.column_names.include?(method_name.to_s) || super
          end
          def @object.class
            #{model_class}
          end
          def @object.to_s
            "#{model_class.name}_#{id}"
          end
        CODE
        yield m if block_given?
        m
      end

      module ModelStubber
        def connection
          raise RSpec::Rails::IllegalDataAccessException.new("stubbed models are not allowed to access the database")
        end
        def new_record?
          __send__(self.class.primary_key).nil?
        end
        def as_new_record
          self.__send__("#{self.class.primary_key}=", nil)
          self
        end
      end

      # :call-seq:
      #   stub_model(Model)
      #   stub_model(Model).as_new_record
      #   stub_model(Model, hash_of_stubs)
      #   stub_model(Model, instance_variable_name, hash_of_stubs)
      #
      # Creates an instance of +Model+ that is prohibited from accessing the
      # database*. For each key in +hash_of_stubs+, if the model has a
      # matching attribute (determined by asking it) are simply assigned the
      # submitted values. If the model does not have a matching attribute, the
      # key/value pair is assigned as a stub return value using RSpec's
      # mocking/stubbing framework.
      #
      # <tt>new_record?</tt> is overridden to return the result of id.nil?
      # This means that by default new_record? will return false. If  you want
      # the object to behave as a new record, sending it +as_new_record+ will
      # set the id to nil. You can also explicitly set :id => nil, in which
      # case new_record? will return true, but using +as_new_record+ makes the
      # example a bit more descriptive.
      #
      # While you can use stub_model in any example (model, view, controller,
      # helper), it is especially useful in view examples, which are
      # inherently more state-based than interaction-based.
      #
      # == Database Independence
      #
      # +stub_model+ does not make your examples entirely
      # database-independent. It does not stop the model class itself from
      # loading up its columns from the database. It just prevents data access
      # from the object itself. To completely decouple from the database, take
      # a look at libraries like unit_record or NullDB.
      #
      # == Examples
      #
      #   stub_model(Person)
      #   stub_model(Person).as_new_record
      #   stub_model(Person, :id => 37)
      #   stub_model(Person) do |person|
      #     person.first_name = "David"
      #   end
      def stub_model(model_class, stubs={})
        primary_key = model_class.primary_key.to_sym
        stubs = {primary_key => next_id}.merge(stubs)
        model_class.new.tap do |m|
          m.__send__("#{primary_key}=", stubs.delete(primary_key))
          m.extend ModelStubber
          m.stub(stubs)
          yield m if block_given?
        end
      end

    private

      @@model_id = 1000

      def next_id
        @@model_id += 1
      end

    end
  end
end

RSpec.configure do |c|
  c.include RSpec::Rails::Mocks
end

