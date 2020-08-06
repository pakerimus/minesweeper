require 'rails_helper'

RSpec.describe "Games", type: :request do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let!(:game) { create(:game, user: user) }
  let(:base_url) { "/api/users/#{user.id}/games" }

  describe "GET index" do
    context "when the user has games" do
      it "returns http success" do
        get base_url
        expect(response).to have_http_status(:success)
      end

      it "returns the list of games" do
        get base_url
        parsed_response = JSON.parse response.body
        expect(parsed_response['games'].count).to eq 1
      end
    end

    context "when the user doesn't have games" do
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
        get "#{base_url}/#{game.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns the correct game" do
        get "#{base_url}/#{game.id}"
        parsed_response = JSON.parse response.body
        expect(parsed_response['game']['id']).to eq game.id
      end
    end

    context "when the user is incorrect" do
      it "raises an error" do
        get "/api/users/#{another_user.id}/games/#{game.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST create" do
    context "when sending empty params" do
      xit "returns an error" do

      end
    end

    context "when sending bad params" do
      xit "returns an error" do

      end
    end

    context "when sending good params" do
      xit "creates the game" do

      end
    end
  end

  describe "DELETE destroy" do
    xit "deletes the game" do

    end

    xit "deletes the board" do

    end
  end

  describe "PATCH update" do
    context "when sending empty params" do
      xit "returns an error" do

      end
    end

    context "when sending bad params" do
      xit "returns an error" do

      end
    end

    context "when sending good params" do
      xit "executes an action" do

      end

      xit "returns the correct data" do

      end
    end
  end
end
