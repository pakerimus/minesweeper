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
end
