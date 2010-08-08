# Gotchas

## Name conflicts with upstream dependencies

Examples in rspec-rails mix in Rails' assertion modules, which mix in assertion
libraries from Minitest (if available) or Test::Unit. This makes it easy to
accidentally override a method defined in one of those upstream modules in an
example.

For example, if you have a model named `Message`, and you define a `message`
method (using `def message` or `let(:message)` in an example group, it will
override Minitest's `message` method, which is used internally by Minitest, and
is also a public API of Minitest. In this case, you would need to use a
different method name or work with instance variables instead of methods.
