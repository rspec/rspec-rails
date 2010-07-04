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
      
      # Creates a mock object instance for a +model_class+ with common
      # methods stubbed out. Additional methods may be easily stubbed (via
      # add_stubs) if +stubs+ is passed.
      def mock_model(model_class, options_and_stubs = {})
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
          def @object.class
            #{model_class}
          end
          def @object.to_s
            "#{model_class.name}_#{id}"
          end

          def @object.model_name
            "#{model_class}"
          end
        CODE
        yield m if block_given?
        m
      end
      
      module ModelStubber
        def connection
          raise Spec::Rails::IllegalDataAccessException.new("stubbed models are not allowed to access the database")
        end
        def new_record?
          id.nil?
        end
        def as_new_record
          self.id = nil
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
        stubs = {:id => next_id}.merge(stubs)
        returning model_class.new do |m|
          m.id = stubs.delete(:id)
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
