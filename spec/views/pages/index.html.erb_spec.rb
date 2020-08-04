require 'rails_helper'

RSpec.describe "pages/index.html.erb", type: :view do
  it "mounts the vue app" do
    render
    expect(rendered).to match /minesweeper_app/
  end
end
