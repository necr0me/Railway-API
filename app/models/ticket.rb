class Ticket < ApplicationRecord
  before_destroy { seat&.update(is_taken: false) }

  belongs_to :profile
  belongs_to :seat
  belongs_to :departure_point, foreign_key: :departure_stop_id, class_name: "TrainStop", inverse_of: :departure_tickets
  belongs_to :arrival_point, foreign_key: :arrival_stop_id, class_name: "TrainStop", inverse_of: :arrival_tickets

  validates :price, presence: true, numericality: { only_float: true, greater_than: 0 }

  delegate :arrival_time, to: :arrival_point
  delegate :departure_time, to: :departure_point
end
