ActiveRecord::Schema.define(version: 1) do
  create_table :posts, force: true do |t|
    t.string :title
    t.timestamps
  end
end
