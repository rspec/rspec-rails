require 'rspec/rails/matchers/exist'
require 'rspec/rails/matchers/contain'
require 'rspec/rails/matchers/be_a_migration'
require 'rails/generators'

module RSpec::Rails
  # Delegates to Rails::Generators::TestCase to work with RSpec.
  module GeneratorExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    DELEGATED_METHODS = [:generator, :destination_root_is_set?, :capture, :ensure_current_path,
                         :prepare_destination, :destination_root, :current_path, :generator_class]
    module ClassMethods
      mattr_accessor :test_unit_test_case_delegate
      delegate :default_arguments, :to => :'self.test_unit_test_case_delegate'
      DELEGATED_METHODS.each do |method|
        delegate method,  :to => :'self.test_unit_test_case_delegate'
      end
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
      delegate :run_generator, :destination, :arguments, :to => :'self.class'
      DELEGATED_METHODS.each do |method|
        delegate method,  :to => :'self.class'
      end
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

    def file relative
      File.expand_path(relative, destination_root)
    end
  end
end