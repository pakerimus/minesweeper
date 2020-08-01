require 'rails_helper'

RSpec.describe "Cells", type: :request do
  let(:cell) { create(:cell) }
  let(:game) { cell.game }
  let(:user) { game.user }

  describe "GET index" do
    it "returns http success" do
      get "/api/users/#{user.id}/games/#{game.id}/cells"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET show" do
    it "returns http success" do
      get "/api/users/#{user.id}/games/#{game.id}/cells/#{cell.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
