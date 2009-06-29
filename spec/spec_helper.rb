$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../../core/lib'))
require 'spec/core'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../lib'))
require 'spec/mocks'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../../expectations/lib'))
require 'spec/expectations'

module Macros
  def treats_method_missing_as_private(options = {:noop => true, :subject => nil})
    it "should have method_missing as private" do
      with_ruby 1.8 do
        self.class.describes.private_instance_methods.should include("method_missing")
      end
      with_ruby 1.9 do
        self.class.describes.private_instance_methods.should include(:method_missing)
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

Spec::Core.configure do |config|
  config.mock_with :rspec
  config.extend(Macros)
  config.include(Spec::Matchers)
  config.include(Spec::Mocks::Methods)
end
