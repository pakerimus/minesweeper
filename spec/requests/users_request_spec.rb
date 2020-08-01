require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/users" do
    context 'when no params are sent' do
      it "fails" do
        post "/api/users"
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when invalid params are sent' do
      it "fails" do
        post "/api/users", params: { foo: 'bar' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when a existing user is sent as param' do
      it "succedes" do
        post "/api/users", params: { user: { name: 'pakerimus' } }
        expect(response).to have_http_status(:success)
      end

      it "creates an user" do
        post "/api/users", params: { user: { name: 'pakerimus' } }
        parsed_response = JSON.parse response.body
        expect(parsed_response['user']['name']).to eq 'pakerimus'
      end
    end

    context 'when a new user is sent as param' do
      it "succedes" do
        post "/api/users", params: { user: { name: user.name } }
        expect(response).to have_http_status(:success)
      end

      it "returns the correct user" do
        post "/api/users", params: { user: { name: user.name } }
        parsed_response = JSON.parse response.body
        expect(parsed_response['user']['id']).to eq user.id
      end
    end
  end
end
