require "spec_helper"
require "autotest/rails_rspec2"

describe Autotest::RailsRspec2 do
  before(:each) do
    rails_rspec2_autotest = Autotest::RailsRspec2.new
    @re = rails_rspec2_autotest.exceptions
  end

  it "should match './log/test.log'" do
    @re.should match('./log/test.log')
  end

  it "should match 'log/test.log'" do
    @re.should match('log/test.log')
  end

  it "should not match './spec/models/user_spec.rb'" do
    @re.should_not match('./spec/models/user_spec.rb')
  end

  it "should not match 'spec/models/user_spec.rb'" do
    @re.should_not match('spec/models/user_spec.rb')
  end
end
