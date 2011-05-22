require 'spec_helper'

describe "be_a_migration" do

  let(:migration_files) { ['db/migrate/20110504132601_create_posts.rb', 'db/migrate/20110520132601_create_users.rb'] }

  before do
    File.stub(:exist?).and_return(false)
    migration_files.each do |migration_file|
      File.stub(:exist?).with(migration_file).and_return(true)
    end
    Dir.stub!(:glob).with('db/migrate/[0-9]*_*.rb').and_return(migration_files)
  end
  it 'should find for the migration file with timestamp in filename' do
    'db/migrate/create_users.rb'.should be_a_migration
  end
  it 'should know when a migration does not exist' do
    'db/migrate/create_comments.rb'.should_not be_a_migration
  end
end
