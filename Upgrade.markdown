# Upgrade to rspec-rails-2

## What's changed

### View specs

Rails changed the way it renders partials, so to set an expectation that a partial
gets rendered:

    view.should_receive(:_render_partial).
      with(hash_including(:partial => "widget/row"))

