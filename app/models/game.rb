class Game < ApplicationRecord
  belongs_to :user
  has_many :cells, dependent: :destroy

  validates :width, :height, :bombs, :state, presence: true
  validates :width, :height, :bombs, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 10
  }

  DEFAULT_STATE = 'pending'.freeze

  enum state: {
    pending: 'pending',
    started: 'started',
    paused: 'paused',
    abandoned: 'abandoned',
    lost: 'lost',
    won: 'won'
  }

  before_validation :set_defaults
  after_create :create_board

  def set_defaults
    self.state ||= DEFAULT_STATE
  end

  def create_board
    GameService::Game.new(self).create_board!
  end

  def available_plays
    cells.normal.not_cleared.count
  end

  def finished?
    abandoned? || lost? || won?
  end

  def place_bombs(starting_cell)
    eligible_cells = cells.normal.where.not(id: starting_cell.id)
    bombs.times do
      random_normal_cell = eligible_cells.reload.sample
      random_normal_cell.place_bomb!
    end
  end
end
