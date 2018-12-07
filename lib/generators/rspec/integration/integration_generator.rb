require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class IntegrationGenerator < Base
      # Add a deprecation for this class, before rspec-rails 4, to use the
      # `RequestGenerator` instead
      class_option :request_specs,
                   :type => :boolean,
                   :default => true,
                   :desc => "Generate request specs"
      class_option :api, :type => :boolean, :desc => "Creates request_spec for APIs, skip specs unnecessary for API-only apps"
      class_option :fabrication, :type => :boolean, :desc => "Fill params with Fabricator model attributes"
      class_option :factory, :type => :boolean, :desc => "Fill params with Factory Bot aka Factory Girl model attributes"


      def initialize(*args, &blk)
        @generator_args = args.first
        super(*args, &blk)
      end

      def generate_request_spec
        return unless options[:request_specs]

        template_file = File.join(
            'spec/requests',
            class_path,
            "#{table_name}_requests_spec.rb"
        )

        if options[:api]
          template 'api_request_spec.rb', File.join('spec/requests', class_path, "#{ns_suffix}_spec.rb")
        else
          template 'request_spec.rb',
                   File.join('spec/requests', class_path, "#{table_name}_spec.rb")
        end

      end

      protected

      attr_reader :generator_args

      # @todo refactor the following methods. They are also in the /lib/generators/rpsec/scaffold/scaffold_generator.rb file.

      def ns_file_name
        return file_name if ns_parts.empty?
        "#{ns_prefix.map(&:underscore).join('/')}_#{ns_suffix.singularize.underscore}"
      end

      # support for namespaced-resources
      def ns_table_name
        return table_name if ns_parts.empty?
        "#{ns_prefix.map(&:underscore).join('/')}/#{ns_suffix.tableize}"
      end

      def ns_parts
        @ns_parts ||= begin
          parts = generator_args[0].split(/\/|::/)
          parts.size > 1 ? parts : []
        end
      end

      def ns_prefix
        @ns_prefix ||= ns_parts[0..-2]
      end

      def ns_suffix
        @ns_suffix ||= ns_parts[-1]
      end
    end
  end
end
