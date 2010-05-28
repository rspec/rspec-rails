require "spec_helper"

module RSpec::Rails
  describe ViewRendering do
    it "doesn't render views by default" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
        rendering_views = render_views?
        it("does something") {}
      end
      group.run(double.as_null_object)
      rendering_views.should be_false
    end

    it "doesn't render views by default in a nested group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
        describe "nested" do
          rendering_views = render_views?
          it("does something") {}
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_false
    end

    it "renders views if told to" do
      rendering_views = false
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
        render_views
        rendering_views = render_views?
        it("does something") {}
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end

    it "renders views if told to in a nested group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
        describe "nested" do
          render_views
          rendering_views = render_views?
          it("does something") {}
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end

    it "renders views in a nested group if told to in an outer group" do
      rendering_views = nil
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
        render_views
        describe "nested" do
          rendering_views = render_views?
          it("does something") {}
        end
      end
      group.run(double.as_null_object)
      rendering_views.should be_true
    end
  end
end
