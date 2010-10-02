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

        # === Rails-3.0.1 and up calls down to this
        def view_assigns
          super.merge(_encapsulated_assigns)
        end

        # === Rails-3.0.0 calls down to this
        def _assigns
          super.merge(_encapsulated_assigns)
        end

        def _encapsulated_assigns
          @_encapsulated_assigns ||= {}
        end
      end
    end
  end
end
