require 'spec_helper'
require 'generators/rspec/install/install_generator'

describe Rspec::Generators::InstallGenerator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  it "generates .rspec" do
    run_generator
    file('.rspec').should exist
  end

  it "generates spec/spec_helper.rb" do
    run_generator
    File.read( file('spec/spec_helper.rb') ).should =~ /^require 'rspec\/autorun'$/m
  end

  if ::Rails.version >= '4'
    it "generates spec/spec_helper.rb with a check for pending migrations" do
      run_generator
      File.read( file('spec/spec_helper.rb') ).should =~ /ActiveRecord::Migration\.check_pending!/m
    end
  else
    it "generates spec/spec_helper.rb without a check for pending migrations" do
      run_generator
      File.read( file('spec/spec_helper.rb') ).should_not =~ /ActiveRecord::Migration\.check_pending!/m
    end
  end
end
