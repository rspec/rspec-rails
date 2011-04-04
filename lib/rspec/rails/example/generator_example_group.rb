### These contecpts copied from Railties Rails::Generators::TestCase which makes it possible to test generators with TestUnit
### https://github.com/rails/rails/blob/master/railties/lib/rails/generators/test_case.rb
module RSpec::Rails
  module GeneratorExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::RailsExampleGroup

    module ClassMethods
      def generator_class
        describes
      end
    end

    module InstanceMethods
      # attr_reader :controller, :routes
      attr_accessor :destination_root

      # You can provide a configuration hash as second argument. This method returns the output
      # printed by the generator.
      def generator(args=[], options={}, config={})
        destination_root ||= Rails.root
        self.class.generator_class.new(args, options, config.reverse_merge(:destination_root => destination_root))
      end

      # Silently run the generator.  Output is given back as return value.
      def run_generator(args=[], options={}, config={})
        capture(:stdout) {
          generator(args, options, config).invoke_all
        }
      end

      # Captures the given stream and returns it:
      #
      #   stream = capture(:stdout){ puts "Cool" }
      #   stream # => "Cool\n"
      #
      def capture(stream)
        begin
          stream = stream.to_s
          eval "$#{stream} = StringIO.new"
          yield
          result = eval("$#{stream}").string
        ensure
          eval("$#{stream} = #{stream.upcase}")
        end

        result
      end

    end

    included do
      subject { generator }

      metadata[:type] = :generator
    end

  end
end