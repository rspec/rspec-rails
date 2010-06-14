module RSpec
  module Rails
    module ViewAssigns
      extend ActiveSupport::Concern

      module InstanceMethods
        # :call-seq:
        #   assign(:widget, stub_model(Widget))
        #
        # Assigns a value to an instance variable in the scope of the
        # view being rendered.
        def assign(key, value)
          _encapsulated_assigns[key] = value
        end

      private

        def _encapsulated_assigns
          @_encapsulated_assigns ||= {}
        end

        def _assigns
          super.merge(_encapsulated_assigns)
        end
      end
    end
  end
end
