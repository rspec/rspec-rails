require 'generator_helper'
# Generators are not automatically loaded by Rails
require 'generators/rspec/integration/integration_generator'

RSpec.describe Rspec::Generators::IntegrationGenerator, :type => :generator do
  setup_default_destination
  it_behaves_like "a request spec generator"
end
