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

  validate :departure_cannot_be_less_than_arrival,
           :way_should_exist,
           :way_should_be_free

  default_scope { order("departure_time ASC") }

  scope :arrives_after, ->(date) { where(arrival_time: date..) }
  scope :arrives_at_the_day, lambda { |date|
    where(arrival_time: date.day == Time.now.utc.day ? Time.now.utc : date.at_beginning_of_day..date.at_end_of_day)
  }
  scope :arrives_before, ->(date) { where(arrival_time: Time.now.utc..date.at_end_of_day) }

  def first?
    id == train.first_stop.id
  end

  def last?
    id == train.last_stop.id
  end

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

  def way_should_exist
    return unless way_number > station&.number_of_ways || way_number < 1

    errors.add(:way_number, message: "does not exist")
  end

  def way_should_be_free
    return if TrainStops::WayCheckerService.call(station: station, train_stop: self).success?

    errors.add(:way_number, message: "#{way_number} is taken")
  end
end
