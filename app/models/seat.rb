class Seat < ApplicationRecord
  belongs_to :carriage

  validates :number, comparison: { greater_than_or_equal_to: 1 }
end
