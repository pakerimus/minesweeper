class Cell < ApplicationRecord
  belongs_to :game

  enum mark: {
    no_mark: 'Blank',
    question: 'Question',
    with_bomb: 'With bomb'
  }

  validates :row, :column, presence: true, numericality: { only_integer: true }

  scope :bombs, -> { where(bomb: true) }
  scope :normal, -> { where(bomb: false) }

  scope :cleared, -> { where(cleared: true) }
  scope :not_cleared, -> { where(cleared: false) }

  scope :by_position, ->(row, column) { where(row: row, column: column) }
end
