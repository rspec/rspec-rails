If you type `script/rails generate`, the only RSpec generator you'll actually see
is `rspec:install`. That's because RSpec is registered with Rails as the test
framework, so whenever you generate application components like models,
controllers, etc, RSpec specs are generated instead of Test::Unit tests.

Note that the generators are there to help you get started, but they are no
substitute for writing your own examples, and they are only guaranteed to work
out of the box for with Rails' defaults (ActiveRecord, no Capybara or Webrat).

Additionally, it is possible to run stand alone rspec generators. For instance, 

    rails generate rspec:model NAME 

will create a new spec file in `spec/models/NAME_spec.rb`.
 
The same generator pattern is available for all specs:

* scaffold 
* model 
* controller 
* helper 
* view
* mailer 
* observer 
* integration 
