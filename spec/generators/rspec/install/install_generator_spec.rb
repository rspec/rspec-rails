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

  it "should create the controlles folder" do
    run_generator
    File.directory?(file("spec/controllers")).should be_true
  end

  it "should create the helpers folder" do
    run_generator
    File.directory?(file("spec/helpers")).should be_true
  end

  it "should create the models folder" do
    run_generator
    File.directory?(file("spec/models")).should be_true
  end

  it "should create the views folder" do
    run_generator
    File.directory?(file("spec/views")).should be_true
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
