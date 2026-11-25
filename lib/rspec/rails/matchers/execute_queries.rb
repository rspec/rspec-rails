module RSpec
  module Rails
    module Matchers
      # @api private
      #
      # Matcher class for `execute_queries` and `execute_no_queries`.
      #
      # @see RSpec::Rails::Matchers#execute_queries
      # @see RSpec::Rails::Matchers#execute_no_queries
      class ExecuteQueries < RSpec::Rails::Matchers::BaseMatcher
        # @private
        def initialize(expected)
          @expected = expected
          @match = nil
          @include_schema = false
        end

        # @private
        def matches?(subject)
          counter = SQLCounter.new

          @queries = ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
            subject.call
            @include_schema ? counter.log_all : counter.log
          end

          @queries.select! { |q| @match === q } unless @match.nil?
          @actual = @queries.count

          if @expected.nil?
            @actual >= 1
          else
            @expected == @actual
          end
        end

        # @api public
        # @see RSpec::Rails::Matchers::execute_queries
        def matching(match)
          @match = match
          self
        end

        # @api public
        # @see RSpec::Rails::Matchers::execute_queries
        def including_schema
          @include_schema = true
          self
        end

        # @private
        def failure_message
          "expected block to #{description}, got #{@actual}"
        end

        # @private
        def failure_message_when_negated
          "expected block to not #{description}, got #{@actual}"
        end

        # @private
        def description
          message = if @expected.nil?
                      "execute 1 or more"
                    else
                      "execute #{@expected}"
                    end
          message << " SQL #{"query".pluralize(@expected)}"
          message << " (including schema operations)" if @include_schema
          message << " matching #{@match.inspect}" unless @match.nil?
          message
        end

        # @private
        def supports_block_expectations?
          true
        end

        private

        def query_word
          "query".pluralize(@expected)
        end
      end

      # @api public
      # Passes if the number of SQL queries executed by the block is exactly
      # `number_of_queries`. If `number_of_queries` is omitted, it passes if it
      # executes 1 or more SQL queries.
      #
      # Use the `matching` method to specify a regular expression to filter the
      # queries.
      #
      # Use the `including_schema` method to include schema related queries.
      #
      # @example
      #     expect { Post.first }.to execute_queries(1)
      #     expect { Post.first }.to execute_queries.matching(/SELECT/)
      #     expect { Post.columns }.to execute_queries(1).including_schema
      def execute_queries(number_of_queries = nil)
        ExecuteQueries.new(number_of_queries)
      end

      # @api public
      # Passes if the block executes no SQL queries.
      #
      # Use the `matching` method to specify a regular expression to filter the
      # queries.
      #
      # Use the `including_schema` method to include schema related queries.
      #
      # @example
      #     expect { Post.first }.to execute_no_queries
      #     expect { Post.first }.to execute_no_queries.matching(/SELECT/)
      #     expect { Post.columns }.to execute_no_queries.including_schema
      def execute_no_queries
        execute_queries(0)
      end

      # Extracted from activerecord/lib/active_record/testing/query_assertions.rb
      # @private
      class SQLCounter
        attr_reader :log_full, :log_all

        def initialize
          @log_full = []
          @log_all = []
        end

        def log
          @log_full.map(&:first)
        end

        def call(*, payload)
          return if payload[:cached]

          sql = payload[:sql]
          @log_all << sql

          unless payload[:name] == "SCHEMA"
            bound_values = (payload[:binds] || []).map do |value|
              value = value.value_for_database if value.respond_to?(:value_for_database)
              value
            end

            @log_full << [sql, bound_values]
          end
        end
      end
    end
  end
end
