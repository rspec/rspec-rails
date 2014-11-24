RSpec.describe 'RSpec::Rails::Railtie', :skip => 'Requires a fast rails app' do

  before do
    build_app
    boot_rails
  end

  after do
    teardown_app
  end

  specify "the action mailer preview path is set to the RSpec path" do
    expect(app('development').config.action_mailer.preview_path).to eq(
      'oops'
    )
  end

end
