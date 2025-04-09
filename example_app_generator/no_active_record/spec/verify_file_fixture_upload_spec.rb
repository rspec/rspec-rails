require 'rails_helper'

RSpec.describe 'Example App', :use_fixtures, type: :model do
  if ::Rails::VERSION::STRING < "7.1.0"
    it 'supports fixture_file_upload' do
      file = fixture_file_upload(__FILE__)
      expect(file.read).to match(/RSpec\.describe 'Example App'/im)
    end
  else
    it 'supports file_fixture_upload' do
      file = file_fixture_upload(__FILE__)
      expect(file.read).to match(/RSpec\.describe 'Example App'/im)
    end

    it 'supports fixture_file_upload' do
      file = fixture_file_upload(__FILE__)
      expect(file.read).to match(/RSpec\.describe 'Example App'/im)
    end
  end
end
