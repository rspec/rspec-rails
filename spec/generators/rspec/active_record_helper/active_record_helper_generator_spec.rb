require 'spec_helper'
require 'generators/rspec/active_record_helper/active_record_helper_generator'

describe Rspec::Generators::ActiveRecordHelperGenerator, :type => :generator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  it "generates spec/active_record_helper.rb" do
    run_generator
    expect(File.read( file('spec/active_record_helper.rb') )).to match(/^require 'active_record'$/m)
  end
end
