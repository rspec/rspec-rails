module RSpec
  module Rails
    module Specs
      module Generators
        module Macros
          # Tell the generator where to put its output (what it thinks of as
          # Rails.root)
          def set_default_destination
            destination File.expand_path('../../tmp', __dir__)
          end

          def setup_default_destination
            set_default_destination
            before { prepare_destination }
          end
        end

        def self.included(klass)
          klass.extend(Macros)
          klass.include(RSpec::Rails::FeatureCheck)
        end

        RSpec.shared_examples_for 'a model generator with fixtures' do |name, class_name|
          before { run_generator [name, '--fixture'] }

          describe 'the spec' do
            subject(:model_spec) { file("spec/models/#{name}_spec.rb") }

            it 'contains the standard boilerplate' do
              expect(model_spec).to contain(/require 'rails_helper'/).and(contain(/^RSpec.describe #{class_name}, #{type_metatag(:model)}/))
            end
          end

          describe 'the fixtures' do
            subject(:filename) { file("spec/fixtures/#{name}.yml") }

            it 'contains the standard boilerplate' do
              expect(filename).to contain(Regexp.new('# Read about fixtures at https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html'))
            end
          end
        end

        RSpec.shared_examples_for "a request spec generator" do
          describe 'generated with flag `--no-request-specs`' do
            before do
              run_generator %w[posts --no-request-specs]
            end

            subject(:request_spec) { file('spec/requests/posts_spec.rb') }

            it "does not create the request spec" do
              expect(File.exist?(request_spec)).to be false
            end
          end

          describe 'generated with no flags' do
            before do
              run_generator name
            end

            subject(:request_spec) { file(spec_file_name) }

            context 'When NAME=posts' do
              let(:name) { %w[posts] }
              let(:spec_file_name) { 'spec/requests/posts_spec.rb' }

              it 'contains the standard boilerplate' do
                expect(request_spec).to contain(/require 'rails_helper'/)
                                          .and(contain(/^RSpec.describe "Posts", #{type_metatag(:request)}/))
                                          .and(contain(/describe "GET \/posts"/))
                                          .and(contain(/get posts_index_path/))
              end
            end

            context 'When NAME=api/posts' do
              let(:name) { %w[api/posts] }
              let(:spec_file_name) { 'spec/requests/api/posts_spec.rb' }

              it 'contains the standard boilerplate' do
                expect(request_spec).to contain(/require 'rails_helper'/)
                                          .and(contain(/^RSpec.describe "Api::Posts", #{type_metatag(:request)}/))
                                          .and(contain(/describe "GET \/api\/posts"/))
                                          .and(contain(/get api_posts_index_path\n/))
              end
            end
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Rails::Specs::Generators, type: :generator
end
