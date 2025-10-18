require 'rails_helper'

RSpec.describe 'Example App', type: :model do
  it "does not set up fixtures" do
    expect(defined?(fixtures)).not_to be
  end
end
