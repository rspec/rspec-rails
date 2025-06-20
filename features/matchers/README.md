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

### error reporting

```ruby
# passes if Rails.error.report was called with specific error instance and message
expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError.new("message"))
```
