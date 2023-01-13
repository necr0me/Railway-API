class Station < ApplicationRecord
  has_many :station_order_numbers, dependent: :destroy
  has_many :routes, through: :station_order_numbers

  auto_strip_attributes :name, squish: true

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 50},
            uniqueness: true
end
