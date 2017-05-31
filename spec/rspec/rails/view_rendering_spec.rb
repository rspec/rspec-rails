require "spec_helper"

module RSpec::Rails
  describe ViewRendering do
    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        def controller
          ActionController::Base.new
        end
        include ViewRendering
      end
    end

    context "default" do
      context "ActionController::Base" do
        it "does not render views" do
          expect(group.new.render_views?).to be_falsey
        end

        it "does not render views in a nested group" do
          expect(group.describe{}.new.render_views?).to be_falsey
        end
      end

      context "ActionController::Metal" do
        it "renders views" do
          group.new.tap do |example|
            def example.controller
              ActionController::Metal.new
            end
            expect(example.render_views?).to be_truthy
          end
        end
      end
    end

    describe "#render_views" do
      context "with no args" do
        it "tells examples to render views" do
          group.render_views
          expect(group.new.render_views?).to be_truthy
        end
      end

      context "with true" do
        it "tells examples to render views" do
          group.render_views true
          expect(group.new.render_views?).to be_truthy
        end

        it "does not log a message that rendering was prevented" do
          subscriber = RSpec::Rails::ViewRendering::EmptyTemplateResolver::LogSubscriber.new
          allow(subscriber).to receive(:current_example_group).and_return group
          expect(subscriber).to_not receive(:info)
          group.render_views true
          subscriber.render_template(nil)
        end
      end

      context "with false" do
        it "tells examples not to render views" do
          group.render_views false
          expect(group.new.render_views?).to be_falsey
        end

        it "overrides the global config if render_views is enabled there" do
          allow(RSpec.configuration).to receive(:render_views?).and_return true
          group.render_views false
          expect(group.new.render_views?).to be_falsey
        end

        it "logs a message that rendering was prevented" do
          subscriber = RSpec::Rails::ViewRendering::EmptyTemplateResolver::LogSubscriber.new
          allow(subscriber).to receive(:current_example_group).and_return group
          expect(subscriber).to receive(:info).with /render_views/
          group.render_views false
          subscriber.render_template(nil)
        end
      end

      it 'propogates to examples in nested groups properly' do
        value = :unset

        group.class_exec do
          render_views

          describe "nested" do
            it { value = render_views? }
          end
        end.run(double.as_null_object)

        expect(value).to eq(true)
      end

      context "in a nested group" do
        let(:nested_group) do
          group.describe{}
        end

        context "with no args" do
          it "tells examples to render views" do
            nested_group.render_views
            expect(nested_group.new.render_views?).to be_truthy
          end
        end

        context "with true" do
          it "tells examples to render views" do
            nested_group.render_views true
            expect(nested_group.new.render_views?).to be_truthy
          end
        end

        context "with false" do
          it "tells examples not to render views" do
            nested_group.render_views false
            expect(nested_group.new.render_views?).to be_falsey
          end
        end

        it "leaves the parent group as/is" do
          group.render_views
          nested_group.render_views false
          expect(group.new.render_views?).to be_truthy
        end

        it "overrides the value inherited from the parent group" do
          group.render_views
          nested_group.render_views false
          expect(nested_group.new.render_views?).to be_falsey
        end

        it "passes override to children" do
          group.render_views
          nested_group.render_views false
          expect(nested_group.describe{}.new.render_views?).to be_falsey
        end
      end
    end

    context 'when render_views? is false' do
      let(:controller) { ActionController::Base.new }

      before { controller.extend(ViewRendering::EmptyTemplates) }

      it 'supports manipulating view paths' do
        controller.prepend_view_path 'app/views'
        controller.append_view_path 'app/others'
        expect(controller.view_paths.map(&:to_s)).to match_paths 'app/views', 'app/others'
      end

      it 'supports manipulating view paths with arrays' do
        controller.prepend_view_path ['app/views', 'app/legacy_views']
        controller.append_view_path ['app/others', 'app/more_views']
        expect(controller.view_paths.map(&:to_s)).to match_paths 'app/views', 'app/legacy_views', 'app/others', 'app/more_views'
      end

      it 'supports manipulating view paths with resolvers' do
        expect {
          controller.prepend_view_path ActionView::Resolver.new
          controller.append_view_path ActionView::Resolver.new
        }.to_not raise_error
      end

      def match_paths(*paths)
        eq paths.map { |path| File.expand_path path }
      end
    end

    context "when a view is rendered in an example group that doesn't include ViewRendering" do
      let(:view) do
        ActionView::Base.new
      end

      before do
        # We need to set ActiveSupport::LogSubscriber.logger here so that events will be properly logged.
        # https://github.com/rails/rails/blob/v5.1.1/activesupport/lib/active_support/log_subscriber.rb#L83
        logger = double('ActiveSupport::LogSubscriber.logger').as_null_object
        allow(ActiveSupport::LogSubscriber).to receive(:logger).and_return(logger)
      end

      def logger
        ActiveSupport::LogSubscriber.logger
      end

      it 'does not cause an error' do
        expect(logger).not_to receive(:error).with(a_string_starting_with('Could not log "render_template.action_view" event.'))
        view.render(body: 'foo')
      end
    end
  end
end
