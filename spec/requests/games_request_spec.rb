require 'rails_helper'

RSpec.describe "Games", type: :request do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let!(:game) { create(:game, user: user) }

  describe "GET index" do
    context "when the user is correct" do
      it "returns http success" do
        get "/api/users/#{user.id}/games"
        expect(response).to have_http_status(:success)
      end

      it "returns the list of games" do
        get "/api/users/#{user.id}/games"
        parsed_response = JSON.parse response.body
        expect(parsed_response['games'].first['id']).to eq game.id
      end
    end

    context "when the user is incorrect" do
      it "returns http success" do
        get "/api/users/#{another_user.id}/games"
        expect(response).to have_http_status(:success)
      end

      it "returns an empty list of games" do
        get "/api/users/#{another_user.id}/games"
        parsed_response = JSON.parse response.body
        expect(parsed_response['games']).to be_empty
      end
    end
  end

  describe "GET show" do
    context "when the user is correct" do
      it "returns http success" do
        get "/api/users/#{user.id}/games/#{game.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns the correct game" do
        get "/api/users/#{user.id}/games/#{game.id}"
        parsed_response = JSON.parse response.body
        expect(response).to have_http_status(:success)
      end
    end

    context "when the user is incorrect" do
      it "raises an error" do
        get "/api/users/#{another_user.id}/games/#{game.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
