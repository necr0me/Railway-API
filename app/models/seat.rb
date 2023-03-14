class Seat < ApplicationRecord
  belongs_to :carriage

  has_one :ticket, dependent: :delete

  default_scope -> { order(number: :asc) }

  validates :number, comparison: { greater_than_or_equal_to: 1 }
end
