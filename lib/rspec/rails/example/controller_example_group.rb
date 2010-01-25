require 'action_dispatch'

module ControllerExampleGroupBehaviour
  include ActionDispatch::Assertions
  include ActionDispatch::Integration::Runner

  def self.included(mod)
    mod.before { @_result = Struct.new(:add_assertion).new }
  end

  def app 
    self.class.described_class.action(@_action)
  end

  %w[get post put delete head].map do |method|
    eval <<-CODE
      def #{method}(action)
        @_action = action
        super '/'
      end
    CODE
  end

  Rspec::Core.configure do |c|
    c.include self, :behaviour => { :file_path => /\/spec\/controllers\// }
  end
end
