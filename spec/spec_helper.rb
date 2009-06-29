require 'spec/deprecation'
require 'spec/ruby'
require 'spec/matchers'
require 'spec/expectations'
require 'spec/example'
require 'spec/runner'
require 'spec/version'
require 'spec/dsl'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec/mocks'

module Macros
  def treats_method_missing_as_private(options = {:noop => true, :subject => nil})
    it "should have method_missing as private" do
      with_ruby 1.8 do
        described_class.private_instance_methods.should include("method_missing")
      end
      with_ruby 1.9 do
        described_class.private_instance_methods.should include(:method_missing)
      end
    end

    it "should not respond_to? method_missing (because it's private)" do
      formatter = options[:subject] || described_class.new({ }, StringIO.new)
      formatter.should_not respond_to(:method_missing)
    end

    if options[:noop]
      it "should respond_to? all messages" do
        formatter = described_class.new({ }, StringIO.new)
        formatter.should respond_to(:just_about_anything)
      end

      it "should respond_to? anything, when given the private flag" do
        formatter = described_class.new({ }, StringIO.new)
        formatter.respond_to?(:method_missing, true).should be_true
      end
    end
  end
end

module Spec  
  # module Example
  #   class NonStandardError < Exception; end
  # end
  # 
  module Matchers
    # def fail
    #   raise_error(Spec::Expectations::ExpectationNotMetError)
    # end
    # 
    # def fail_with(message)
    #   raise_error(Spec::Expectations::ExpectationNotMetError, message)
    # end
    # 
    # def exception_from(&block)
    #   exception = nil
    #   begin
    #     yield
    #   rescue StandardError => e
    #     exception = e
    #   end
    #   exception
    # end
    # 
    # def run_with(options)
    #   ::Spec::Runner::CommandLine.run(options)
    # end
    # 
    def with_ruby(version)
      yield if RUBY_VERSION =~ Regexp.compile("^#{version.to_s}")
    end
  end
end

module Spec
  module Example
    class ExampleGroupDouble < ExampleGroup
      ::Spec::Runner.options.remove_example_group self
      def register_example_group(klass)
        #ignore
      end
      def initialize(proxy=nil, &block)
        super(proxy || ExampleProxy.new, &block)
      end
    end
  end
end


Spec::Runner.configure do |config|
  config.extend(Macros)
  config.include(Spec::Matchers)
end
