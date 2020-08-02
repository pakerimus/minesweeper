require 'rails_helper'

RSpec.describe Cell, type: :model do
  let(:cell) { build(:cell) }

  it "has a valid factory" do
    expect(cell).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:row) }
    it { is_expected.to validate_presence_of(:column) }
  end

  describe '#next_mark' do
    subject { cell.next_mark }

    before { cell.mark = mark }

    context 'when mark is nil' do
      let(:mark) { nil }

      it { is_expected.to eq 'question' }
    end

    context "when mark is blank" do
      let(:mark) { '' }

      it { is_expected.to eq 'question' }
    end

    context "when mark is no_mark" do
      let(:mark) { 'no_mark' }

      it { is_expected.to eq 'question' }
    end

    context "when mark is question" do
      let(:mark) { 'question' }

      it { is_expected.to eq 'with_bomb' }
    end

    context "when mark is with_bomb" do
      let(:mark) { 'with_bomb' }

      it { is_expected.to eq 'no_mark' }
    end
  end

  describe '#adjacent_cells' do
    subject(:adjacent_cells) { cell.adjacent_cells }

    let(:game) { create(:game) }

    context "when cell is a corner" do
      let(:cell) { game.cells.by_position(1, 1).take }

      it { expect(adjacent_cells.count).to eq 4 }
    end

    context "when cell is a border" do
      let(:cell) { game.cells.by_position(1, 2).take }

      it { expect(adjacent_cells.count).to eq 6 }
    end

    context "when cell is not a border" do
      let(:cell) { game.cells.by_position(2, 2).take }

      it { expect(adjacent_cells.count).to eq 9 }
    end
  end

  describe '#calculate_adjacent_bombs' do
    subject { cell_1.calculate_adjacent_bombs }

    let(:game) { create(:game) }
    let(:cell_1) { game.cells.by_position(1, 1).take }
    let(:cell_2) { game.cells.by_position(1, 2).take }

    before { cell_2.place_bomb! }

    it "calculates the total adjacent bombs" do
      expect { subject }.to change(cell_1, :adjacent_bombs).from(0).to(1)
    end
  end
end
