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
      expect(game.cells).not_to be_empty
    end

    it "deletes the board when destroyed" do
      expect { game.destroy }.to change(game.cells, :count).from(game.board_size).to(0)
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

  describe '#finished?' do
    subject { game.finished? }

    let(:state) { nil }
    let(:game) { build(:game, state: state) }

    context "when state is nil" do
      it { is_expected.to be false }
    end

    context "when state is blank" do
      let(:state) { '' }

      it { is_expected.to be false }
    end

    context "when state equals pending" do
      let(:state) { 'pending' }

      it { is_expected.to be false }
    end

    context "when state equals started" do
      let(:state) { 'started' }

      it { is_expected.to be false }
    end

    context "when state equals paused" do
      let(:state) { 'paused' }

      it { is_expected.to be false }
    end

    context "when state equals abandoned" do
      let(:state) { 'abandoned' }

      it { is_expected.to be true }
    end

    context "when state equals lost" do
      let(:state) { 'lost' }

      it { is_expected.to be true }
    end

    context "when state equals won" do
      let(:state) { 'won' }

      it { is_expected.to be true }
    end
  end

  describe '#board_size' do
    subject { game.board_size }

    let(:game) { build(:game, width: 20, height: 20) }

    it { is_expected.to eq 400 }
  end
end
