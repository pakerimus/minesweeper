require 'rails_helper'

RSpec.describe "Cells", type: :request do
  let(:game) { create(:game) }
  let(:cell) { game.cells.first }
  let(:user) { game.user }
  let(:another_user) { create(:user) }
  let(:base_url) { "/api/users/#{user.id}/games/#{game.id}/cells" }

  describe "GET index" do
    context "when the user has games" do
      it "returns http success" do
        get base_url
        expect(response).to have_http_status(:success)
      end

      it "returns the list of cells" do
        get base_url
        parsed_response = JSON.parse response.body
        expect(parsed_response['cells'].count).to eq (game.board_size)
      end
    end

    context "when the user doesn't have games" do
      it "returns http success" do
        get "/api/users/#{another_user.id}/games/#{game.id}/cells"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET show" do
    context "when the user is correct" do
      it "returns http success" do
        get "#{base_url}/#{cell.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns the correct cell" do
        get "#{base_url}/#{cell.id}"
        parsed_response = JSON.parse response.body
        expect(parsed_response['cell']['id']).to eq cell.id
      end
    end

    context "when the user is incorrect" do
      it "raises an error" do
        get "/api/users/#{another_user.id}/games/#{game.id}/cells/#{cell.id}"
        expect(response).to have_http_status(:not_found)
      end
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
