require 'generator_helper'
# Generators are not automatically loaded by Rails
require 'generators/rspec/request/request_generator'

RSpec.describe Rspec::Generators::RequestGenerator, :type => :generator do
  setup_default_destination
  it_behaves_like "a request spec generator"
end
