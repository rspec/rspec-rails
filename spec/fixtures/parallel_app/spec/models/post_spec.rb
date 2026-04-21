require "rails_helper"

RSpec.describe Post do
  it "starts empty" do
    expect(Post.count).to eq(0)
  end

  it "records the worker number in the database file name" do
    worker = RSpec.parallel_worker_number
    skip "not running in parallel" if worker.nil?
    db = ActiveRecord::Base.connection_db_config.database
    expect(db).to match(/test[-_.]?(sqlite3)?[-_]#{worker}(\.sqlite3)?\z/)
  end
end
