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
# passes when any error is reported
expect { Rails.error.report(StandardError.new) }.to have_reported_error

# passes when specific error class is reported
expect { Rails.error.report(MyError.new) }.to have_reported_error(MyError)

# passes when specific error class with exact message is reported
expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError, "message")

# passes when specific error class with message matching pattern is reported
expect { Rails.error.report(MyError.new("test message")) }.to have_reported_error(MyError, /test/)

# passes when any error with exact message is reported
expect { Rails.error.report(StandardError.new("exact message")) }.to have_reported_error("exact message")

# passes when any error with message matching pattern is reported
expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(/test/)

# passes when error is reported with specific context attributes
expect { Rails.error.report(StandardError.new, context: { user_id: 123 }) }.to have_reported_error.with_context(user_id: 123)
```
