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
    c.include self, :behaviour => { :describes => lambda {|c| c < ::ActionController::Base} }
  end
end


# describe WidgetsController do
  # context "GET index" do
    # it "does something" do
      # get :index
      # response.body.should == "this text"
    # end
  # end
# end

