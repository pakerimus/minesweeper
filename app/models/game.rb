class Game < ApplicationRecord
  belongs_to :user

  validates :width, :heigth, :bombs, :state, presence: true
  validates :width, :heigth, :bombs, numericality: {
    only_integer: true,
    greater_than: 10
  }

  before_validation :set_defaults

  def set_defaults
    state ||= "pending"
  end
end
