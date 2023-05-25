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

  validate :arrival_cannot_be_less_than_departure_of_last_stop, on: :create

  validate :arrival_cannot_be_less_than_departure_of_previous_stop,
           :departure_cannot_be_greater_than_arrival_of_next_stop, on: :update

  validate :departure_cannot_be_less_than_arrival

  default_scope { order("departure_time ASC") }

  scope :arrives_after, ->(date) { where(arrival_time: date..) }
  scope :arrives_at_the_day, ->(date) { where(arrival_time: date.at_beginning_of_day..date.at_end_of_day) }
  scope :arrives_before, ->(date) { where(arrival_time: ..date) }

  def next_stop
    train.stops.where("id > ?", id).first
  end

  def previous_stop
    train.stops.where("id < ?", id).last
  end

  private

  def departure_cannot_be_less_than_arrival
    return unless departure_time < arrival_time

    errors.add(:departure_time, "can't be less than arrival time")
  end

  def arrival_cannot_be_less_than_departure_of_last_stop
    return unless train&.last_stop.present? && arrival_time < train.last_stop.departure_time

    errors.add(:arrival_time, message: "can't be less than departure time of last stop")
  end

  def arrival_cannot_be_less_than_departure_of_previous_stop
    return unless previous_stop.present? && arrival_time < previous_stop.departure_time

    errors.add(:arrival_time, message: "can't be less than departure time of previous stop")
  end

  def departure_cannot_be_greater_than_arrival_of_next_stop
    return unless next_stop.present? && departure_time > next_stop.arrival_time

    errors.add(:departure_time, message: "can't be greater than arrival time of next stop")
  end
end
