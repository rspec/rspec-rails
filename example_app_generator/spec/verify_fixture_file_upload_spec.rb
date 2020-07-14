require 'rails_helper'

RSpec.describe 'Example App' do
  it 'fixture_file_upload correctly resolves' do
    expect(fixture_file_upload('file_upload.txt', 'plain/text').tempfile.read).to eq('Hello World')
  end
end
