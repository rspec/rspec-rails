# Generators are not automatically loaded by Rails
require "generators/rspec/channel/channel_generator"
require 'support/generators'

RSpec.describe Rspec::Generators::ChannelGenerator, type: :generator, skip: !RSpec::Rails::FeatureCheck.has_action_cable_testing? do
  setup_default_destination

  before { run_generator %w[chat] }

  subject(:channel_spec) { file("spec/channels/chat_channel_spec.rb") }

  it "generates a channel spec file" do
    expect(channel_spec).to contain(/require 'rails_helper'/).and(contain(/describe ChatChannel, #{type_metatag(:channel)}/))
  end
end
