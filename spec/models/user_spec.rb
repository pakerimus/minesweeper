require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  describe 'validations' do
    context "when user already exists" do
      let(:user) { build(:user, name: 'pakerimus') }

      before { create(:user, name: 'pakerimus') }

      it { expect(user).to be_invalid }
    end
  end
end
