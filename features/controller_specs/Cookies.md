Controller specs wrap Rails controller tests, which expose a few different ways
to access cookies:

    @request.cookies['key']
    @response.cookies['key']
    cookies['key']

rails-3.0.x and 3.1 handle these slightly differently, so to avoid confusion, we recommend
the following guidelines:

### Recommended guidelines for rails-3.0.0 to 3.1.0

  * Access cookies through the `request` and `response` objects in the spec.
    * Use `request.cookies` before the action to set up state.
    * Use `response.cookies` after the action to specify outcomes.
  * Use the `cookies` object in the controller action. 
  * Use String keys.

<pre>
# spec
request.cookies['foo'] = 'bar'
get :some_action
expect(response.cookies['foo']).to eq('modified bar')

# controller
def some_action
  cookies['foo'] = "modified #{cookies['foo']}"
end
</pre>

#### Why use Strings instead of Symbols?

The `cookies` objects in the spec come from Rack, and do not support
indifferent access (i.e. `:foo` and `"foo"` are different keys). The `cookies`
object in the controller _does_ support indifferent access, which is a bit
confusing.

This changed in rails-3.1, so you _can_ use symbol keys, but we recommend
sticking with string keys for consistency.

#### Why not use the `cookies` method?

The `cookies` method combines the `request` and `response` cookies. This can
lead to confusion when setting cookies in the example in order to set up state
for the controller action. 

    # does not work in rails 3.0.0 > 3.1.0
    cookies['foo'] = 'bar' # this is not visible in the controller
    get :some_action

### Future versions of Rails

There is code in the master branch in rails that makes cookie access more
consistent so you can use the same `cookies` object before and after the action, 
and you can use String or Symbol keys. We'll update these docs accordingly when
that is released.

