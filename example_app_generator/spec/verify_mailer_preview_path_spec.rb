require 'rails_helper'
require 'rspec/rails/feature_check'

RSpec.describe 'Action Mailer railtie hook' do
  CaptureExec = Struct.new(:io, :exit_status) do
    def ==(str)
      io == str
    end
  end

  def capture_exec(*ops)
    io = if RUBY_VERSION.to_f < 1.9
           IO.popen(ops.join(' '))
         else
           ops << { :err => [:child, :out] }
           IO.popen(ops)
         end
    # Necessary to ignore warnings from Rails code base
    out =  io.readlines.reject { |line|
      line =~ /warning: circular argument reference/
    }.join.chomp
    CaptureExec.new(out, $?.exitstatus)
  end

  def have_no_preview
    have_attributes(:io => be_blank, :exit_status => 0)
  end

  let(:exec_script) {
    File.expand_path(File.join(__FILE__, '../support/default_preview_path'))
  }

  if RSpec::Rails::FeatureCheck.has_action_mailer_show_preview?
    context 'in the development environment' do
      let(:custom_env) { { 'RAILS_ENV' => rails_env } }
      let(:rails_env) { 'development' }

      it 'sets the preview path to the default rspec path' do
        expect(capture_exec(custom_env, exec_script)).to eq(
          "#{::Rails.root}/spec/mailers/previews"
        )
      end

      it 'respects the setting from `show_previews`' do
        expect(
          capture_exec(
            custom_env.merge('SHOW_PREVIEWS' => 'false'),
            exec_script
          )
        ).to have_no_preview
      end

      it 'respects a custom `preview_path`' do
        expect(
          capture_exec(
            custom_env.merge('CUSTOM_PREVIEW_PATH' => '/custom/path'),
            exec_script
          )
        ).to eq('/custom/path')
      end

      it 'allows initializers to set options' do
        expect(
          capture_exec(
            custom_env.merge('DEFAULT_URL' => 'test-host'),
            exec_script
          )
        ).to eq('test-host')
      end

      it 'handles action mailer not being available' do
        expect(
          capture_exec(
            custom_env.merge('NO_ACTION_MAILER' => 'true'),
            exec_script
          )
        ).to have_no_preview
      end
    end

    context 'in a non-development environment' do
      let(:custom_env) { { 'RAILS_ENV' => rails_env } }
      let(:rails_env) { 'test' }

      it 'does not set the preview path by default' do
        expect(capture_exec(custom_env, exec_script)).to have_no_preview
      end

      it 'respects the setting from `show_previews`' do
        expect(
          capture_exec(custom_env.merge('SHOW_PREVIEWS' => 'true'), exec_script)
        ).to eq("#{::Rails.root}/spec/mailers/previews")
      end

      it 'allows initializers to set options' do
        expect(
          capture_exec(
            custom_env.merge('DEFAULT_URL' => 'test-host'),
            exec_script
          )
        ).to eq('test-host')
      end

      it 'handles action mailer not being available' do
        expect(
          capture_exec(
            custom_env.merge('NO_ACTION_MAILER' => 'true'),
            exec_script
          )
        ).to have_no_preview
      end
    end
  elsif RSpec::Rails::FeatureCheck.has_action_mailer_preview?
    context 'in the development environment', 'without `show_previews`' do
      let(:custom_env) { { 'RAILS_ENV' => rails_env } }
      let(:rails_env) { 'development' }

      it 'sets the preview path to the default rspec path' do
        expect(capture_exec(custom_env, exec_script)).to eq(
          "#{::Rails.root}/spec/mailers/previews"
        )
      end

      it 'respects a custom `preview_path`' do
        expect(
          capture_exec(
            custom_env.merge('CUSTOM_PREVIEW_PATH' => '/custom/path'),
            exec_script
          )
        ).to eq('/custom/path')
      end

      it 'allows initializers to set options' do
        expect(
          capture_exec(
            custom_env.merge('DEFAULT_URL' => 'test-host'),
            exec_script
          )
        ).to eq('test-host')
      end

      it 'handles action mailer not being available' do
        expect(
          capture_exec(
            custom_env.merge('NO_ACTION_MAILER' => 'true'),
            exec_script
          )
        ).to have_no_preview
      end
    end

    context 'in a non-development environment', 'without `show_previews`' do
      let(:custom_env) { { 'RAILS_ENV' => rails_env } }
      let(:rails_env) { 'test' }

      it 'does not set the preview path by default' do
        expect(capture_exec(custom_env, exec_script)).to have_no_preview
      end

      it 'respects a custom `preview_path`' do
        expect(
          capture_exec(
            custom_env.merge('CUSTOM_PREVIEW_PATH' => '/custom/path'),
            exec_script
          )
        ).to eq('/custom/path')
      end

      it 'handles action mailer not being available' do
        expect(
          capture_exec(
            custom_env.merge('NO_ACTION_MAILER' => 'true'),
            exec_script
          )
        ).to have_no_preview
      end
    end
  else
    it 'handles no action mailer preview' do
      expect(capture_exec(exec_script)).to have_no_preview
    end
  end
end
