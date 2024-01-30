# Matchers

rspec-rails offers a number of custom matchers, most of which are
rspec-compatible wrappers for Rails' assertions.

### redirects

```ruby
    # delegates to assert_redirected_to
    expect(response).to redirect_to(path)
```

### templates

```ruby
    # delegates to assert_template
    expect(response).to render_template(template_name)
```

### assigned objects

```ruby
    # passes if assigns(:widget) is an instance of Widget
    # and it is not persisted
    expect(assigns(:widget)).to be_a_new(Widget)
```
