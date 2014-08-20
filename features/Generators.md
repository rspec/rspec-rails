RSpec spec are normally generated alongside other application components.
For instance, `rails generate model` will also generate an RSpec spec file
for the model.

Note that the generators are there to help you get started, but they are no
substitute for writing your own examples, and they are only guaranteed to work
out of the box for with Rails' defaults.

RSpec generators can also be run independently. For instance,

    rails generate rspec:model widget

will create a new spec file in `spec/models/widget_spec.rb`.

The same generator pattern is available for all specs:

* scaffold
* model
* controller
* helper
* view
* mailer
* observer
* integration
* feature

There is also a generator to generate a spec helper that can be used to
test ActiveRecord based models in isolation from the rest of Rails. It is
installed using `rails generate rspec:active_record_helper`.

Please note that this is a more specialized and advanced pattern for testing
Rails applications and may not work out of the box with existing applications.
