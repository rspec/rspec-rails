# Upgrade to rspec-rails-2

## Controller specs

### render_views

Controller specs, by default, do _not_ render views. This helps keep the
controller specs focused on the controller. Use `render_views` instead of
rspec-1's `integrate_views` to tell the spec to render the views:

    describe WidgetController do
      render_views
      
      describe "GET index" do
        ...

## View specs

Rails changed the way it renders partials, so to set an expectation that a partial
gets rendered:

    view.should_receive(:_render_partial).
      with(hash_including(:partial => "widget/row"))

