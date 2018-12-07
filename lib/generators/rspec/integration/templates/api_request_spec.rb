require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.


<% module_namespacing do -%>
RSpec.describe <%= class_name.pluralize %>Controller, <%= type_metatag(:request) %> do

  # This should return the minimal set of attributes required to create a valid
  # <%= class_name %>. As you add validations to <%= class_name %>, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
<% if options[:factorybot] || Gem.loaded_specs.has_key?('factory_bot_rails') -%>
     attributes_for(:<%= ns_file_name -%>)
<% elsif options[:fabrication] || Gem.loaded_specs.has_key?('fabrication')-%>
    Fabricate.attributes_for(<%= ns_prefix.empty? ? ":"+ns_file_name : "'#{class_name}'"-%>)
<% else -%>
    skip("Add a hash of attributes valid for your model")
<% end -%>
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # <%= class_name %>Controller. Be sure to keep this updated too.
  # Because it's an API request a default JSON header is added.
  # If you have an Authentication - and you definitely should - add your token header here.
  let(:valid_headers) {
    {
      "Content-Type" => "application/json"
    }
  }

<% unless options[:singleton] -%>
  describe "GET #index" do
    it "returns a success response" do
      <%= file_name %> = <%= class_name %>.create! valid_attributes

      get <%= ns_file_name.pluralize %>_path, params: {}, headers: valid_headers

      expect(response).to be_successful
    end

    it "returns <%= class_name %> objects as json array" do
      <%= file_name %> = <%= class_name %>.create! valid_attributes

      get <%= ns_file_name.pluralize %>_path, params: {}, headers: valid_headers

      expect(JSON.parse(response.body).count).to be 1
    end
  end

<% end -%>
  describe "GET #show" do
    it "returns a success response" do
      <%= file_name %> = <%= class_name %>.create! valid_attributes

      get <%= ns_file_name.pluralize %>_path, params: {id: <%= file_name %>.to_param}, headers: valid_headers

      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new <%= class_name %>" do
        expect {
          post <%= ns_file_name.pluralize %>_path(<%= ns_file_name -%>: valid_attributes), headers: valid_headers

          }.to change(<%= class_name %>, :count).by(1)
      end

      it "renders a JSON response with the new <%= ns_file_name %>" do
        post <%= ns_file_name.pluralize %>_path(<%= ns_file_name -%>: valid_attributes), headers: valid_headers

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(<%= ns_file_name %>_url(<%= class_name %>.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new <%= ns_file_name %>" do
        post <%= ns_file_name.pluralize %>_path(<%= ns_file_name -%>: invalid_attributes), headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
<% if options[:factorybot] || Gem.loaded_specs.has_key?('factory_bot_rails') -%>
        attributes_for(:<%= ns_file_name -%>)
<% elsif options[:fabrication] || Gem.loaded_specs.has_key?('fabrication')-%>
        Fabricate.attributes_for(<%= options[:skip_namespace] ? ":"+ns_file_name : "'#{ns_file_name}'"-%>)
<% else -%>
        skip("Add a hash of attributes valid for your model")
<% end -%>
      }

      it "updates the requested <%= ns_file_name %>" do
        <%= file_name %> = <%= class_name %>.create! valid_attributes
        put <%= ns_file_name %>_path(id: valid_attributes, <%= ns_file_name %>: new_attributes), headers: valid_headers

        <%= file_name %>.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the <%= ns_file_name %>" do
        <%= file_name %> = <%= class_name %>.create! valid_attributes
        put <%= ns_file_name %>_path(id: <%= file_name %>.to_param, <%= ns_file_name %>: new_attributes), headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the <%= ns_file_name %>" do
        <%= file_name %> = <%= class_name %>.create! valid_attributes
        put <%= ns_file_name %>_path(id: <%= file_name %>.to_param, <%= ns_file_name %>: invalid_attributes), headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested <%= ns_file_name %>" do
      <%= file_name %> = <%= class_name %>.create! valid_attributes
      expect {
        delete <%= ns_file_name %>_path(id: <%= file_name %>.to_param), headers: valid_headers
      }.to change(<%= class_name %>, :count).by(-1)
    end
  end
end
<% end -%>
