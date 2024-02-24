require 'rails_helper'

RSpec.describe "verify view path doesn't leak stubs between examples", type: :view, order: :defined do
  subject(:html) do
    render partial: "example"
    rendered
  end

  it "renders the stub template" do
    stub_template("_example.html.erb" => "STUB_HTML")
    expect(html).to include("STUB_HTML")
  end

  it "renders the file template" do
    expect(html).to include("TEMPLATE_HTML")
  end
end
