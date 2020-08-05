require 'rails_helper'

RSpec.describe GameService::Game, type: :service do
  let(:game_svc) { described_class.new(game, options) }
  let(:game) { create(:game) }
  let(:options) { {} }

  describe '#place_bombs' do
    subject(:place_bombs) { game_svc.place_bombs(starting_cell) }

    let(:starting_cell) { game.cells.sample }

    it "places the correct amount of bombs" do
      expect { place_bombs }.to change(game.cells.bombs, :count).from(0).to(game.bombs)
    end

    it "does not place a bomb in the starting cell" do
      expect { place_bombs }.not_to change(starting_cell, :bomb)
    end
  end
end
