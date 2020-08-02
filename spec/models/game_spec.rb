require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { build(:game) }

  it "has a valid factory" do
    expect(game).to be_valid
  end

  describe 'validations' do
    subject { create(:game) }

    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_presence_of(:bombs) }

    it "sets the default state" do
      game.state = nil
      expect(game.valid?).to be true
    end

    it "ensures a valid state" do
      game.state = nil
      game.valid?
      expect(game.state).to eq Game::DEFAULT_STATE
    end

    it "validates the quantity of bombs" do
      game.bombs = 9
      expect(game.valid?).to be false
    end
  end

  describe 'callbacks' do
    let!(:game) { create(:game) }

    it "creates the board after create" do
      expect(game.cells.count).to eq (game.height * game.width)
    end
  end

  describe '#available_plays' do
    subject { game.available_plays }

    let!(:game) { create(:game, width: 10, height: 10, bombs: 10) }

    before { game.cells.limit(game.bombs).update_all(bomb: true) }

    context 'when there are no cleared cells' do
      it { is_expected.to eq 90 }
    end

    context 'when we cleared 40 cells' do
      before do
        game.cells.normal.limit(40).update_all(cleared: true)
        game.reload
      end

      it { is_expected.to eq 50 }
    end

    context 'when we cleared all cells' do
      before do
        game.cells.normal.update_all(cleared: true)
        game.reload
      end

      it { is_expected.to eq 0 }
    end
  end

  describe '#place_bombs' do
    subject(:place_bombs) { game.place_bombs(starting_cell) }

    let(:game) { create(:game) }
    let(:starting_cell) { game.cells.sample }

    it "places the correct amount of bombs" do
      expect { place_bombs }.to change(game.cells.bombs, :count).from(0).to(game.bombs)
    end

    it "does not place a bomb in the starting cell" do
      expect { place_bombs }.not_to change(starting_cell, :bomb)
    end
  end
end
