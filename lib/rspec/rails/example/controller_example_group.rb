require 'action_dispatch'
require 'webrat'

module ControllerExampleGroupBehaviour
  include ActionDispatch::Assertions
  include ActionDispatch::Integration::Runner
  include Webrat::Matchers
  include Webrat::Methods
  include Rspec::Rails::Matchers

  def self.included(mod)
    mod.before { @_result = Struct.new(:add_assertion).new }
  end

  def app 
    self.class.described_class.action(@_action)
  end

  %w[get post put delete head].map do |method|
    eval <<-CODE
      def #{method}(*args)
        @_action = args.shift
        super '/', *args
      end
    CODE
  end

  Rspec::Core.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/controllers\// }
  end
end
