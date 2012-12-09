require 'spec_helper'

<% module_namespacing do -%>
describe <%= class_name %> do
	
	pending "add some examples to (or delete) #{__FILE__}"

	<% unless attributes.empty? %>
	it "should have <%= attributes.map(&:name).join(', ') %> columns in the database" do
		<% attributes.each do |attribute| %>
		should have_db_column(:<%= attribute.name %>)
		<% end  %>  
	end		 
	<% end -%>


end
<% end -%>
