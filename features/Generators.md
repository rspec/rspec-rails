# Using generators

RSpec `_spec.rb` files are normally generated alongside other application components.
For instance, `rails generate model` will also generate an RSpec `_spec.rb` file
for the model.

Note that the generators are there to help you get started, but they are no
substitute for writing your own examples, and they are only guaranteed to work
out of the box for with Rails' defaults.

RSpec generators can also be run independently. For instance,

```console
rails generate rspec:model widget
```

will create a new spec file in `spec/models/widget_spec.rb`.

The same generator pattern is available for all specs:

* channel
* controller
* feature
* generator
* helper
* job
* mailbox
* mailer
* model
* request
* scaffold
* system
* view
