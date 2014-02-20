require 'spec_helper'

<% output_attributes = attributes.reject{|attribute| [:datetime, :timestamp, :time, :date].index(attribute.type) } -%>
describe "<%= ns_table_name %>/new" do
  before(:each) do
    assign(:<%= ns_file_name %>, <%= class_name %>.new(<%= '))' if output_attributes.empty? %>
<% output_attributes.each_with_index do |attribute, attribute_index| -%>
      :<%= attribute.name %> => <%= attribute.default.inspect %><%= attribute_index == output_attributes.length - 1 ? '' : ','%>
<% end -%>
<%= !output_attributes.empty? ? "    ))\n  end" : "  end" %>

  it "renders new <%= ns_file_name %> form" do
    render

    assert_select "form[action=?][method=?]", <%= index_helper %>_path, "post" do
<% for attribute in output_attributes -%>
  <%- if attribute.reference? -%>
      assert_select "<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.column_name %>[name=?]", "<%= ns_file_name %>[<%= attribute.column_name %>]"
  <%- else -%>
      assert_select "<%= attribute.input_type -%>#<%= ns_file_name %>_<%= attribute.name %>[name=?]", "<%= ns_file_name %>[<%= attribute.name %>]"
  <%- end -%>
<% end -%>
    end
  end
end
