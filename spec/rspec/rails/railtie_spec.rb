require 'tmpdir'
require 'rspec-rails'
require 'rails/code_statistics'

if ::Rails::VERSION::STRING >= "8.0.0"
  RSpec.describe RSpec::Rails::Railtie do
    describe "rspec_rails.code_statistics initializer" do
      let(:initializer) { described_class.initializers.find { |i| i.name == "rspec_rails.code_statistics" } }
      let(:registered) { [] }

      around do |example|
        Dir.mktmpdir do |dir|
          @root = Pathname(dir)
          example.run
        end
      end

      before do
        allow(::Rails).to receive(:root).and_return(@root)
        allow(::Rails::CodeStatistics).to receive(:register_directory) { |name, dir, **| registered << [name, dir] }
      end

      def touch(path)
        full = @root.join(path)
        FileUtils.mkdir_p(full.dirname)
        FileUtils.touch(full)
      end

      it "registers each `spec` subdirectory containing a spec file, at any depth" do
        touch 'spec/models/user_spec.rb'
        touch 'spec/features/admin/reports/monthly_spec.rb'
        touch 'spec/support/helpers.rb'
        touch 'spec/fixtures/files/users.yml'
        touch 'spec/spec_helper.rb'
        touch 'spec/root_spec.rb'

        initializer.run

        expect(registered).to eq([
          ["Feature specs", @root.join('spec/features').to_s],
          ["Model specs", @root.join('spec/models').to_s],
        ])
      end

      it "ignores non-word directory names and symlinked directories" do
        touch 'spec/models/user_spec.rb'
        touch 'spec/my-features/a_spec.rb'
        touch 'spec/.hidden/a_spec.rb'
        touch 'spec/fixtures/.hidden/a_spec.rb'
        File.symlink(@root.join('spec/models'), @root.join('spec/aliased'))

        initializer.run

        expect(registered.map(&:first)).to eq(["Model specs"])
      end

      it "registers nothing when there is no `spec` directory" do
        initializer.run

        expect(registered).to eq([])
      end
    end
  end
end
