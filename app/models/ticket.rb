class Ticket < ApplicationRecord
  before_destroy { seat&.update(is_taken: false) }

  belongs_to :profile
  belongs_to :seat
  belongs_to :departure_station, class_name: "Station"
  belongs_to :arrival_station, class_name: "Station"

  validates :price, presence: true, numericality: { only_float: true, greater_than: 0 }
end
