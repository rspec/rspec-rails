require "spec_helper"

describe RSpec::Rails, "version" do
  def clear_memoized_version
    if RSpec::Rails.instance_variable_defined?(:@rails_version)
      RSpec::Rails.send(:remove_instance_variable, :@rails_version)
    end
  end

  before { clear_memoized_version }
  after  { clear_memoized_version }

  describe "#rails_version_satisfied_by?" do
    it "checks whether the gem version constraint is satisfied by the Rails version" do
      ::Rails.stub(:version).and_return(Gem::Version.new("4.0.0"))

      expect(RSpec::Rails.rails_version_satisfied_by?(">=3.2.0")).to be_true
      expect(RSpec::Rails.rails_version_satisfied_by?("~>4.0.0")).to be_true
      expect(RSpec::Rails.rails_version_satisfied_by?("~>3.2.0")).to be_false
    end

    it "operates correctly when the Rails version is a string (pre-Rails 4.0)" do
      ::Rails.stub(:version).and_return("3.2.1")

      expect(RSpec::Rails.rails_version_satisfied_by?("~>3.2.0")).to be_true
      expect(RSpec::Rails.rails_version_satisfied_by?("~>3.1.0")).to be_false
    end
  end
end
