require "rspec/rails/matchers/turbo/have_turbo_stream"
require "rspec/rails/matchers/turbo/have_turbo_frame"

module RSpec
  module Rails
    module Matchers
      # Namespace for various implementations of Turbo features
      #
      # @api private
      module Turbo
      end

      # @api public
      # Passes if the response contains a `<turbo-stream>` element matching
      # the given action and target/targets.
      #
      # @example
      #     expect(response).to have_turbo_stream(action: "append", target: "messages")
      #     expect(response).to have_turbo_stream(action: "replace", target: "post_1")
      #     expect(response).to have_turbo_stream(action: "remove", target: "post_1")
      #     expect(response).to have_turbo_stream(action: "update", targets: ".comments")
      #     expect(response).to have_turbo_stream(action: "append", target: "messages").with_count(2)
      def have_turbo_stream(action:, target: nil, targets: nil)
        Turbo::HaveTurboStream.new(action: action, target: target, targets: targets)
      end

      # @api public
      # Passes if the response has a Turbo Stream content type
      # (`text/vnd.turbo-stream.html`).
      #
      # @example
      #     expect(response).to be_turbo_stream
      def be_turbo_stream
        Turbo::BeTurboStream.new
      end

      # @api public
      # Passes if the response contains a `<turbo-frame>` element with the given id.
      #
      # @example
      #     expect(response).to have_turbo_frame("post_form")
      #     expect(response).to have_turbo_frame("new_comment")
      def have_turbo_frame(id)
        Turbo::HaveTurboFrame.new(id)
      end
    end
  end
end
