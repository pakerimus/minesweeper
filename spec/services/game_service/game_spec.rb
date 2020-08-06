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

  describe "#execute_action!" do
    subject(:execute) { game_svc.execute_action! }

    before { allow(game_svc).to receive(:validate_action!).and_return(nil) }

    context "when pausing a game" do
      let(:game_action) { 'pause' }

      before { game.update(last_started_at: 30.seconds.ago) }

      it { expect { execute }.to change(game, :paused?).to(true) }
      it { expect { execute }.to change(game, :total_time).to(30) }
      it { expect { execute }.to change(game, :last_started_at).to(nil) }
      it { expect { execute }.not_to change(game, :finished?) }
      it { expect { execute }.not_to change(game, :available_plays) }
      it { expect { execute }.not_to change(game.cells.not_cleared, :count) }
    end

    context "when continuing a game" do
      let(:game_action) { 'continue' }

      it { expect { execute }.to change(game, :started?).to(true) }
      it { expect { execute }.to change(game, :last_started_at) }
      it { expect { execute }.not_to change(game, :total_time) }
      it { expect { execute }.not_to change(game, :finished?) }
      it { expect { execute }.not_to change(game, :available_plays) }
      it { expect { execute }.not_to change(game.cells.not_cleared, :count) }

      it "returns the action to refresh the grid" do
        status, message = execute
        expect(message).to eq 'refresh_grid'
      end
    end

    context "when abandoning a game" do
      let(:game_action) { 'abandon' }

      before { game.update(state: 'started', last_started_at: 50.seconds.ago) }

      it { expect { execute }.to change(game, :started?).to(false) }
      it { expect { execute }.to change(game, :last_started_at).to(nil) }
      it { expect { execute }.to change(game, :total_time).to(50) }
      it { expect { execute }.to change(game, :finished?).from(false).to(true) }
      it { expect { execute }.to change(game, :available_plays).to(0) }
      it { expect { execute }.to change(game.cells.not_cleared, :count).to(0) }

      it "returns the action to refresh the grid" do
        status, message = execute
        expect(message).to eq 'refresh_grid'
      end
    end
  end

  describe '#start' do
    subject(:start) { game_svc.start(cell) }

    let(:cell) { game.cells.sample }

    context "when starting cell is not provided" do
      let(:cell) { nil }

      it { expect { start }.to raise_error }
    end

    context "when starting cell is provided" do
      it { expect { start }.to change(game.cells.bombs, :count) }
      it { expect { start }.to change(game, :started?).from(false).to(true) }
    end
  end

  describe '#explode' do
    subject(:explode) { game_svc.explode }

    it { expect { explode }.to change(game, :finished?).from(false).to(true) }
    it { expect { explode }.to change(game, :available_plays).to(0) }
    it { expect { explode }.to change(game.cells.not_cleared, :count).to(0) }
    it { expect { explode }.to change(game, :lost?).from(false).to(true) }
  end

  describe '#calculate_remaining_plays' do
    subject(:calculate) { game_svc.calculate_remaining_plays }

    let(:cell) { game.cells.sample }

    before { game_svc.place_bombs(cell) }

    context "when user has cleared all cells" do
      before do
        game.cells.normal.not_cleared.update_all(cleared: true)
      end

      it { expect { calculate }.to change(game, :finished?).from(false).to(true) }
      it { expect { calculate }.to change(game.cells.not_cleared, :count).to(0) }
      it { expect { calculate }.to change(game, :won?).from(false).to(true) }
      it { is_expected.to eq 'won' }
    end

    context "when user has remaining plays" do
      it { expect { calculate }.not_to change(game, :state) }
      it { is_expected.to be nil }
    end
  end
end
