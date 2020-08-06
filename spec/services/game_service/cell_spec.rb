require 'rails_helper'

RSpec.describe GameService::Cell, type: :service do
  let(:cell_svc) { described_class.new(game, cell, **options) }
  let(:game) { create(:game) }
  let(:cell) { game.cells.sample }
  let(:cell_action) { nil }
  let(:options) { { 'cell_action' => cell_action} }

  describe '#validate_action!' do
    subject(:validate_action) { cell_svc.validate_action! }

    let(:exception) { described_class::InvalidCellActionException }
    let(:err_msg) { 'Invalid action' }

    context "when action is nil" do
      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when action is blank" do
      let(:cell_action) { '' }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to clear a cell in a finished game" do
      let(:cell_action) { 'clear' }
      let(:err_msg) { 'Not allowed: Game has finished' }

      before { game.update(state: 'won') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end

    context "when trying to clear a cell in a pending game" do
      let(:cell_action) { 'clear' }

      it { expect { validate_action }.not_to raise_error }
    end

    context "when trying to clear a cell in a started game" do
      let(:cell_action) { 'clear' }

      before { game.update(state: 'started') }

      it { expect { validate_action }.not_to raise_error }
    end

    context "when trying to clear a cell in a paused game" do
      let(:cell_action) { 'clear' }
      let(:err_msg) { 'Not allowed: Game is paused' }

      before { game.update(state: 'paused') }

      it { expect { validate_action }.to raise_error(exception, err_msg) }
    end
  end

  describe "#clear" do
    subject(:clear) { cell_svc.clear }

    let(:cell_action) { 'clear' }

    context "when game is pending" do
      before { game.pending! }

      it { expect { clear }.to change(cell, :cleared?).from(false).to(true) }
      it { is_expected.to eq 'refresh_grid' }
      it { expect { clear }.to change(game.cells.bombs, :count) }
      it { expect { clear }.to change(game, :started?).to(true) }
    end

    context "when game is not pending" do
      let(:starting_cell) { game.cells.where.not(id: cell.id).sample }

      before { GameService::Game.new(game).start(starting_cell) }

      it { expect { clear }.to change(cell, :cleared?).from(false).to(true) }
      it { expect { clear }.not_to change(game.cells.bombs, :count) }
    end

    context "when cell has a bomb" do
      let(:starting_cell) { game.cells.sample }
      let(:cell) { game.cells.bombs.sample }

      before { GameService::Game.new(game).start(starting_cell) }

      it { expect { clear }.to change(cell, :cleared?).from(false).to(true) }
      it { expect { clear }.to change(game, :state).to('lost') }
    end

    context "when cell has not a bomb and has no adjacent bombs" do
      let(:starting_cell) { game.cells.sample }
      let(:cell) { game.cells.normal.where(adjacent_bombs: 0).sample }

      before { GameService::Game.new(game).start(starting_cell) }

      it { expect { clear }.to change(cell, :cleared?).from(false).to(true) }
      it { expect { clear }.not_to change(game, :lost?) }
      it { is_expected.to eq 'refresh_grid' }
    end

    context "when cell has not a bomb and has adjacent bombs" do
      let(:starting_cell) { game.cells.sample }
      let(:cell) { game.cells.normal.where(adjacent_bombs: 1).sample }

      before { GameService::Game.new(game).start(starting_cell) }

      it { expect { clear }.to change(cell, :cleared?).from(false).to(true) }
      it { expect { clear }.not_to change(game, :lost?) }
      it { is_expected.to be nil }
    end
  end
end
