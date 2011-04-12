require 'rspec/rails/matchers/generate_a_file'

module RSpec::Rails
  # Delegats to Rails::Generators::TestCase to work with RSpec.
  module GeneratorExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    module ClassMethods
      mattr_accessor :test_unit_test_case_delegate
      delegate :generator, :generator_class, :destination_root_is_set?, :capture, :ensure_current_path, :prepare_destination, :destination_root, :current_path, :generator_class, :default_arguments, :to => :'self.test_unit_test_case_delegate'
      delegate :destination, :arguments, :to => :'self.test_unit_test_case_delegate.class'

      def initialize_delegate
        self.test_unit_test_case_delegate = Rails::Generators::TestCase.new 'default_test'
        self.test_unit_test_case_delegate.class.tests(describes)
      end

      def run_generator(given_args=self.default_arguments, config={})
        args, opts = Thor::Options.split(given_args)
        capture(:stdout) { generator(args, opts, config).invoke_all }
      end
    end

    module InstanceMethods
      def invoke_task name
        capture(:stdout) { generator.invoke_task(generator_class.all_tasks[name.to_s]) }
      end
    end

    included do
      delegate :generator, :run_generator, :destination_root_is_set?, :capture, :ensure_current_path, :prepare_destination, :destination, :destination_root, :current_path, :generator_class, :arguments, :to => :'self.class'
      initialize_delegate

      subject { generator }

      before do
        self.class.initialize_delegate
        destination_root_is_set?
        ensure_current_path
      end
      after do
        ensure_current_path
      end
      metadata[:type] = :generator
    end

    def absolute_filename relative
      File.expand_path(relative, destination_root)
    end

    # Copied from Rails::Generators::TestCase because that method is protected
    def migration_file_name(relative) #:nodoc:
      absolute = absolute_filename(relative)
      dirname, file_name = File.dirname(absolute), File.basename(absolute).sub(/\.rb$/, '')
      Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{file_name}.rb$/).first
    end
  end
end