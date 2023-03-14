class Route < ApplicationRecord
  has_many :station_order_numbers, dependent: :delete_all
  has_many :stations, through: :station_order_numbers
  # TODO: add 'destination' column that stores names of first and last stations in route
  has_many :trains, dependent: :nullify
end
