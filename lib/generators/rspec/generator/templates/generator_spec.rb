require 'rails_helper'
require '<%= generator_path %>'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>Generator, <%= type_metatag(:generator) %> do
  pending "add some examples to (or delete) #{__FILE__}"
end
<% end -%>
