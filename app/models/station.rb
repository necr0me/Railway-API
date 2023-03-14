class Station < ApplicationRecord
  has_many :station_order_numbers, dependent: :delete_all
  has_many :routes, through: :station_order_numbers

  has_many :passing_trains, dependent: :delete_all
  has_many :trains, through: :passing_trains

  has_many :arrival_tickets, class_name: 'Ticket', foreign_key: :arrival_station_id, dependent: :destroy,
                             inverse_of: :arrival_station
  has_many :departure_tickets, class_name: 'Ticket', foreign_key: :departure_station_id, dependent: :destroy,
                               inverse_of: :departure_station

  auto_strip_attributes :name, squish: true

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 50 },
            uniqueness: true
end
