# Active Record

`rspec-rails` by default injects [ActiveSupport::TestCase](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html) and exposes some of the settings to RSpec configuration.
Furthermore it adds special hooks into `before` and `after` which are essential for [Active Record Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html) and keeping the database in a clean state.

It provides the `fixtures` class method in the rspec context to tell Rails which fixtures to prepare before each example.

In addition to being available in the database, the fixture’s data may also be accessed by using a special dynamic method, which has the same name as the model.

```ruby
RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
end

RSpec.describe Thing, type: :model do
  fixtures :things

  it "fixture method defined" do
    expect(things(:one)).to eq(Thing.find_by(name: "one"))
  end
end
```

More details on how to use fixtures are in the [Rails documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html#class-ActiveRecord::FixtureSet-label-Using+Fixtures+in+Test+Cases)

## Transactions

When you run `rails generate rspec:install`, the `spec/rails_helper.rb` file
includes the following configuration:

```ruby
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
```

The name of this setting is a bit misleading. What it really means in Rails
is "run every test method within a transaction." In the context of rspec-rails,
it means "run every example within a transaction."

The idea is to start each example with a clean database, create whatever data
is necessary for that example, and then remove that data by simply rolling back
the transaction at the end of the example.

For how this affects methods exposing transaction visibility see:
https://guides.rubyonrails.org/testing.html#transactions

### Data created in `before` are rolled back

Any data you create in a `before` hook will be rolled back at the end of
the example. This is a good thing because it means that each example is
isolated from state that would otherwise be left around by the examples that
already ran. For example:

```ruby
describe Widget do
  before do
    @widget = Widget.create
  end

  it "does something" do
    expect(@widget).to do_something
  end

  it "does something else" do
    expect(@widget).to do_something_else
  end
end
```

The `@widget` is recreated in each of the two examples above, so each example
has a different object, _and_ the underlying data is rolled back so the data
backing the `@widget` in each example is new.

### Data created in `before(:context)` are _not_ rolled back

`before(:context)` hooks are invoked before the transaction is opened. You can use
this to speed things up by creating data once before any example in a group is
run, however, this introduces a number of complications and you should only do
this if you have a firm grasp of the implications. Here are a couple of
guidelines:

1.  Be sure to clean up any data in an `after(:context)` hook:

    ```ruby
    before(:context) do
      @widget = Widget.create!
    end

    after(:context) do
      @widget.destroy
    end
    ```

    If you don't do that, you'll leave data lying around that will eventually
interfere with other examples.

2.  Reload the object in a `before` hook.

    ```ruby
    before(:context) do
      @widget = Widget.create!
    end

    before do
      @widget.reload
    end
    ```

Even though database updates in each example will be rolled back, the
object won't _know_ about those rollbacks so the object and its backing
data can easily get out of sync.

## Configuration

### Disabling Active Record support

If you prefer to manage the data yourself, or using another tool like
[database_cleaner](https://github.com/bmabey/database_cleaner) to do it for you,
simply tell RSpec to tell Rails not to manage fixtures and cleaning database.

```ruby
RSpec.configure do |config|
  config.use_active_record = false # is true by default
end
```

### Fixtures path

The generator will provide the default path to the fixture, but it is possible to change it:
```ruby
RSpec.configure do |config|
  config.fixture_paths = Rails.root.join('some/dir') # Rails.root.join('spec/fixtures') by default
end
```

### Instantiated fixtures

If you want to have your fixtures available as an instance variable in the example, you could use `use_instantiated_fixtures` option:

```ruby
RSpec.configure do |config|
  config.use_instantiated_fixtures = true # false, by default
end

RSpec.describe Thing, type: :model do
  fixtures :things

  it "instantiates fixtures" do
    expect(@things["one"]).to eq(@one)
  end
end
```

### Global fixtures

Sometimes it is required to have some fixture in each example, and it's possible to do this via `global_fixtures` setting:

```ruby
RSpec.configure do |config|
  config.global_fixtures = [:things]
end

RSpec.describe Thing, type: :model do
  it "inserts fixture" do
    expect(things(:one)).to be_a(Thing)
  end
end
```

### Disabling transactions

If your database does not support transactions, but you still want to use Rails fixtures, it is possible to disable transactions explicitly:

```ruby
RSpec.configure do |config|
  config.use_transactional_fixtures = false
end
```
