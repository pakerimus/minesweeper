class Cell < ApplicationRecord
  belongs_to :game

  enum mark: {
    no_mark: 'Blank',
    question: 'Question',
    with_bomb: 'With bomb'
  }

  validates :row, :column, presence: true, numericality: { only_integer: true }
  validates :game_id, uniqueness: { scope: [:row, :column] }

  scope :bombs, -> { where(bomb: true) }
  scope :normal, -> { where(bomb: false) }

  scope :cleared, -> { where(cleared: true) }
  scope :not_cleared, -> { where(cleared: false) }

  scope :by_position, ->(row, column) { where(row: row, column: column) }

  def next_mark
    next_index = Cell.marks.keys.find_index(mark) + 1
    next_index = 0 if next_index == Cell.marks.count
    Cell.marks.keys[next_index]
  end

  def cycle_mark
    self.mark = next_mark
  end

  def cycle_mark!
    cycle_mark
    save!
  end

  def without_adjacent_bombs?
    adjacent_bombs.zero?
  end

  def can_be_cleared?
    return false if cleared?

    no_mark?
  end

  def clear!
    update!(cleared: true)
  end

  def place_bomb!
    update!(bomb: true)
  end

  def adjacent_cells
    game.cells.by_position([row-1..row+1], [column-1..column+1])
  end

  def calculate_adjacent_bombs
    bombs = adjacent_cells.where.not(id: id).bombs.count
    update(adjacent_bombs: bombs)
  end
end
