require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper')

describe <%= controller_class_name %>Controller do

  def <%= mock_file_name %>(stubs={})
    @<%= mock_file_name %> ||= mock_model(<%= class_name %>, stubs)
  end

  <% unless options[:singleton] -%>
  describe "GET index" do
    it "assigns all <%= table_name.pluralize %> as @<%= table_name.pluralize %>" do
      <%= stub! orm_class.all(class_name) %>.and_return([<%= mock_file_name %>])
      get :index
      assigns[:<%= table_name %>].should == [<%= mock_file_name %>]
    end
  end
  <% end -%>

  describe "GET show" do
    it "assigns the requested <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.find(class_name, "37".inspect) %>.and_return(<%= mock_file_name %>)
      get :show, :id => "37"
      assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
    end
  end

  describe "GET new" do
    it "assigns a new <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.build(class_name) %>.and_return(<%= mock_file_name %>)
      get :new
      assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
    end
  end

  describe "GET edit" do
    it "assigns the requested <%= file_name %> as @<%= file_name %>" do
      <%= stub! orm_class.find(class_name, "37".inspect) %>.and_return(<%= mock_file_name %>)
      get :edit, :id => "37"
      assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.build(class_name, params) %>.and_return(<%= mock_file_name(:save => true) %>)
        post :create, :<%= file_name %> => <%= params %>
        assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
      end

      it "redirects to the created <%= file_name %>" do
        <%= stub! orm_class.build(class_name) %>.and_return(<%= mock_file_name(:save => true) %>)
        post :create, :<%= file_name %> => {}
        response.should redirect_to(<%= table_name.singularize %>_url(<%= mock_file_name %>))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.build(class_name, params) %>.and_return(<%= mock_file_name(:save => false) %>)
        post :create, :<%= file_name %> => <%= params %>
        assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
      end

      it "re-renders the 'new' template" do
        <%= stub! orm_class.build(class_name) %>.and_return(<%= mock_file_name(:save => false) %>)
        post :create, :<%= file_name %> => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested <%= file_name %>" do
        <%= should! orm_class.find(class_name, "37".inspect) %>.and_return(<%= mock_file_name %>)
        mock_<%= should! orm_instance.update_attributes(params) %>
        put :update, :id => "37", :<%= file_name %> => <%= params %>
      end

      it "assigns the requested <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.find(class_name) %>.and_return(<%= mock_file_name(:update_attributes => true) %>)
        put :update, :id => "1"
        assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
      end

      it "redirects to the <%= file_name %>" do
        <%= stub! orm_class.find(class_name) %>.and_return(<%= mock_file_name(:update_attributes => true) %>)
        put :update, :id => "1"
        response.should redirect_to(<%= table_name.singularize %>_url(<%= mock_file_name %>))
      end
    end

    describe "with invalid params" do
      it "assigns the <%= file_name %> as @<%= file_name %>" do
        <%= stub! orm_class.find(class_name) %>.and_return(<%= mock_file_name(:update_attributes => false) %>)
        put :update, :id => "1"
        assigns[:<%= file_name %>].should equal(<%= mock_file_name %>)
      end

      it "re-renders the 'edit' template" do
        <%= stub! orm_class.find(class_name) %>.and_return(<%= mock_file_name(:update_attributes => false) %>)
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested <%= file_name %>" do
      <%= should! orm_class.find(class_name, "37".inspect) %>.and_return(<%= mock_file_name %>)
      mock_<%= should! orm_instance.destroy %>
      delete :destroy, :id => "37"
    end

    it "redirects to the <%= table_name %> list" do
      <%= stub! orm_class.find(class_name) %>.and_return(<%= mock_file_name(:destroy => true) %>)
      delete :destroy, :id => "1"
      response.should redirect_to(<%= table_name %>_url)
    end
  end

end
