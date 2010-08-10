# Changes in beta.20

### Webrat or Capybara

rspec-rails-2.0.0.beta.20 removes the dependency and offers you a choice of
using webrat or capybara. Just add the library of your choice to your Gemfile.

# Upgrade to rspec-rails-2

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

Rails changed the way it renders partials, so to set an expectation that a
partial gets rendered:

    render
    view.should render_template(:partial => "widget/_row")

