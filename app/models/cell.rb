class Cell < ApplicationRecord
  belongs_to :game

  enum mark: {
    no_mark: 'Blank',
    question: 'Question',
    with_bomb: 'With bomb'
  }

  validates :row, :column, presence: true, numericality: { only_integer: true }
end
