class TrainStop < ApplicationRecord
  belongs_to :train, inverse_of: :stops
  belongs_to :station, inverse_of: :train_stops

  has_many :arrival_tickets, class_name: "Ticket",
                             foreign_key: :arrival_stop_id,
                             inverse_of: :arrival_point,
                             dependent: :destroy
  has_many :departure_tickets, class_name: "Ticket",
                               foreign_key: :departure_stop_id,
                               inverse_of: :departure_point,
                               dependent: :destroy

  # TODO: add validation of presence (optional)
  validate :arrival_cannot_be_later_than_departure

  default_scope { order("departure_time ASC") }

  scope :arrives_after, ->(date) { where(arrival_time: date..) }
  scope :arrives_at_the_day, ->(date) { where(arrival_time: date.at_beginning_of_day..date.at_end_of_day) }
  scope :arrives_before, ->(date) { where(arrival_time: ..date) }

  private

  def arrival_cannot_be_later_than_departure
    return unless departure_time < arrival_time

    errors.add(:arrival_time, "can't be greater than departure time")
  end
end
