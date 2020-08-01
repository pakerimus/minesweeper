class Game < ApplicationRecord
  belongs_to :user
  has_many :cells

  validates :width, :height, :bombs, :state, presence: true
  validates :width, :height, :bombs, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 10
  }

  before_validation :set_defaults

  def set_defaults
    state ||= "pending"
  end
end
