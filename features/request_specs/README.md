Request specs live in `spec/requests` or any example group with
`:type => request`.

Request specs mix in behavior from Rails' integration tests ([
ActionDispatch::Integration::Runner](http://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)).
Request specs allow you to test your application at a higher
level by simulating an arbitrary request and specifying expected outcomes such
as:

* rendered templates
* redirects
* content in the response body

Request specs can also be used to test the flow as a user completes
a task in the application involving multiple controllers and views.
