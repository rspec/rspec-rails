# rspec-rails-2.3.0

## autotest integration

Add a .rspec file to the project's root directory (if not already there) to
tell RSpec to tell Autotest to use RSpec's specialized Autotest class.

NOTE that rspec-core-2.0, 2.1, and 2.2 required an autotest/discover.rb file in
the project's root directory. This worked with some, but not all versions of
autotest and/or the autotest command that ships with ZenTest. This new approach
will work regardless of which version of autotest/ZenTest you are using.

## Webrat and Capybara

Earlier 2.0.0.beta versions depended on Webrat. As of
rspec-rails-2.0.0.beta.20, this dependency and offers you a choice of using
webrat or capybara. Just add the library of your choice to your Gemfile.

## Controller specs

### islation from view templates

By default, controller specs do _not_ render view templates. This keeps
controller specs isolated from the content of views and their requirements.

NOTE that the template must exist, but it will not be rendered.  This is
different from rspec-rails-1.x, in which the template didn't need to exist, but
ActionController makes a number of new decisions in Rails 3 based on the
existence of the template. To keep the RSpec code free of monkey patches, and
to keep the rspec user experience simpler, we decided that this would be a fair
trade-off.

## View specs

### view.should render_template

Rails changed the way it renders partials, so to set an expectation that a
partial gets rendered, you need 

    render
    view.should render_template(:partial => "widget/_row")

### stub_template

Introduced in rspec-rails-2.2, simulates the presence of view templates on the
file system. This supports isolation from partials rendered by the vew template
that is the subject of a view example:

    stub_template "widgets/_widget.html.erb" => "This Content"

### as_new_record

Earlier versions of the view generators generated stub_model with `:new_record?
=> true`. That is no longer recognized in rspec-rails-2, so you need to change
this:
  
    stub_model(Widget, :new_record? => true)

to this:

    stub_model(Widget).as_new_record

Generators in 2.0.0 final release will do the latter.
