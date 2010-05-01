module Rspec
  module Rails
    module ViewRendering
      extend ActiveSupport::Concern

      module ClassMethods
        def render_views
          metadata[:render_views] = true
        end

        def render_views?
          !!metadata[:render_views]
        end
      end

      included do
        before do
          @_view_paths = controller.class.view_paths
          controller.class.view_paths = [ActionView::NullResolver.new()] unless
            self.class.render_views?
        end

        after do
          controller.class.view_paths = @_view_paths
        end
      end
    end
  end
end
