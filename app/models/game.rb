class Game < ApplicationRecord
  belongs_to :user
  has_many :cells

  validates :width, :height, :bombs, :state, presence: true
  validates :width, :height, :bombs, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 10
  }

  before_validation :set_defaults
  after_create :create_board

  def set_defaults
    self.state ||= "pending"
  end

  def create_board
    GameService::Game.new(self).create_board!
  end

  def plays_available
    cells.normal.not_cleared.count
  end

  def place_bombs(starting_cell)
    bombs.times do
      column = rand(width)
      row = rand(height)
      cell = nil
      while !cell
        cell = game.cells.normal.reload.where.not(id: starting_cell.id).find_by(column: column, row: row)
      end
      random_normal_cell.place_bomb!
    end
  end
end
