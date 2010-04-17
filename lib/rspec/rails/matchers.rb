require 'rspec/matchers'

begin
  require 'test/unit/assertionfailederror'
rescue LoadError
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
end

begin
  require "active_record"
rescue

end

Rspec::Matchers.define :redirect_to do |destination|
  match_unless_raises Test::Unit::AssertionFailedError do |_|
    assert_redirected_to destination
  end
end

Rspec::Matchers.define :render_template do |options, message|
  match_unless_raises Test::Unit::AssertionFailedError do |_|
    assert_template options, message
  end
end

Rspec::Matchers.define :be_a_new do |model_klass|
  match do |actual|
    model_klass === actual && actual.new_record?
  end
end
