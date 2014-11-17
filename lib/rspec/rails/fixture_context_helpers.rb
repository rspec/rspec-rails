module RSpec
  module Rails
    # @private
    module FixtureContextHelpers
      # @private
      module TrackableFixtures
        def known_fixtures
          @_known_fixtures ||= []
        end

        def to_s
          "#{super}(#{known_fixtures.sort.join(', ')})"
        end
        alias_method :inspect, :to_s
      end

    private

      def convert_to_accessors(names)
        names.map { |n| n.to_s.tr('/', '_').to_sym }
      end

      def ensure_prevent_fixture_helpers
        if const_defined?(:PreventFixtures, false)
          const_get(:PreventFixtures, false)
        else
          set_prevent_fixture_helpers
        end
      end

      def prevent_fixture_helpers
        const_get(:PreventFixtures) if const_defined?(:PreventFixtures)
      end

      def prevent_fixtures_in_context(accessor_names)
        return if accessor_names.empty?
        ensure_prevent_fixture_helpers.module_exec do
          (accessor_names - known_fixtures).each do |accessor_name|
            known_fixtures << accessor_name
            define_method(accessor_name) do |*_fixture_names|
              raise <<-EOS
Fixture accessor `#{accessor_name}` invoked in a `before` or `after` context hook at:
  #{CallerFilter.first_non_rspec_line}

Calling fixture accessors from a context hook is not supported.

Active Record fixtures are automatically loaded into the database before each
example. To ensure consistent data, the environment deletes the fixtures before
running the load each time.

Fixture accessor helpers are not intended to be called in a context hook, as
they exist to load database state that is reset between each example, while
`before(:context)` exists to define state that is shared across examples in an
example group and `after(:context)` exists to cleanup state that is shared
across examples in an example group.
EOS
            end
          end
        end
      end

      def set_prevent_fixture_helpers
        existing_helpers = prevent_fixture_helpers
        mod = Module.new do
          extend TrackableFixtures
          include existing_helpers if existing_helpers
        end
        const_set(:PreventFixtures, mod)
      end
    end
  end
end
