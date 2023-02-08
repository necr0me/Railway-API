class Route < ApplicationRecord
  has_many :station_order_numbers, dependent: :delete_all
  has_many :stations, through: :station_order_numbers

  has_many :trains, dependent: :nullify
end
