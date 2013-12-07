require 'spec_helper'
require 'generators/rspec/install/install_generator'

describe Rspec::Generators::InstallGenerator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  it "generates .rspec" do
    run_generator
    expect(file('.rspec')).to exist
  end

  it "generates spec/spec_helper.rb" do
    run_generator
    expect(File.read( file('spec/spec_helper.rb') )).to match(/^require 'rspec\/rails'$/m)
  end

  if ::Rails::VERSION::STRING >= '4'
    it "generates spec/spec_helper.rb with a check for pending migrations" do
      run_generator
      expect(File.read( file('spec/spec_helper.rb') )).to match(/ActiveRecord::Migration\.check_pending!/m)
    end
  else
    it "generates spec/spec_helper.rb without a check for pending migrations" do
      run_generator
      expect(File.read( file('spec/spec_helper.rb') )).not_to match(/ActiveRecord::Migration\.check_pending!/m)
    end
  end
end
