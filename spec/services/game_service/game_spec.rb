require 'rails_helper'

RSpec.describe GameService::Game, type: :service do
  let(:game_svc) { described_class.new(game, **options) }
  let(:game) { create(:game) }
  let(:game_action) { nil }
  let(:options) { { 'game_action' => game_action} }

  describe '#place_bombs' do
    subject(:place_bombs) { game_svc.place_bombs(starting_cell) }

    let(:starting_cell) { game.cells.sample }

    context "when game has not bombs placed" do
      it "places the correct amount of bombs" do
        expect { place_bombs }.to change(game.cells.bombs, :count).from(0).to(game.bombs)
      end

      it "does not place a bomb in the starting cell" do
        expect { place_bombs }.not_to change(starting_cell, :bomb)
      end
    end

    context "when game already has placed bombs" do
      before { place_bombs }

      it "places the correct amount of bombs" do
        expect { place_bombs }.not_to change(game.cells.bombs, :count)
      end
    end
  end

  describe '#validate_action!' do
    subject(:validate_action) { game_svc.validate_action! }

    let(:exception) { described_class::InvalidGameActionException }
    let(:err_msg) { 'Invalid action' }

    context "when action is nil" do
      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when action is blank" do
      let(:game_action) { '' }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when action is reserved (start)" do
      let(:game_action) { 'start' }
      let(:err_msg) { 'Not allowed: Action is reserved' }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when action is reserved (explode)" do
      let(:game_action) { 'explode' }
      let(:err_msg) { 'Not allowed: Action is reserved' }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to play a finished game" do
      let(:game_action) { 'pause' }
      let(:err_msg) { 'Not allowed: Game has finished' }

      before { game.update(state: 'won') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to play a pending game" do
      let(:game_action) { 'pause' }
      let(:err_msg) { 'Not allowed: Game has not started' }

      before { game.update(state: 'pending') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to pause a paused game" do
      let(:game_action) { 'pause' }
      let(:err_msg) { 'Not allowed: redundant' }

      before { game.update(state: 'paused') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to continue a started game" do
      let(:game_action) { 'continue' }
      let(:err_msg) { 'Not allowed: redundant' }

      before { game.update(state: 'started') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end
  end
end
