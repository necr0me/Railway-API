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

  scope :arrives_after, lambda { |date|
    where(arrival_time: [Time.now.utc.getlocal(date.zone), date].max..)
  }
  scope :arrives_at_the_day, lambda { |date|
    where(arrival_time: [Time.now.utc.getlocal(date.zone), date.at_beginning_of_day].max..date.at_end_of_day)
  }
  scope :arrives_before, lambda { |date|
    where(arrival_time: Time.now.utc.getlocal(date.zone)..date.at_end_of_day)
  }

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

    errors.add(:departure_time, "не может быть меньше времени прибытия")
  end

  def arrival_cannot_be_less_than_departure_of_last_stop
    return unless train&.last_stop.present? && arrival_time < train.last_stop.departure_time

    errors.add(:arrival_time, message: "не может быть меньше времени отправления с последней станции")
  end

  def arrival_cannot_be_less_than_departure_of_previous_stop
    return unless previous_stop.present? && arrival_time < previous_stop.departure_time

    errors.add(:arrival_time, message: "не может быть меньше времени отправления с предыдущей станции")
  end

  def departure_cannot_be_greater_than_arrival_of_next_stop
    return unless next_stop.present? && departure_time > next_stop.arrival_time

    errors.add(:departure_time, message: "не может быть больше времени прибытия на следующую станцию")
  end

  def way_should_exist
    return unless way_number > station&.number_of_ways || way_number < 1

    errors.add(:way_number, message: "не существует")
  end

  def way_should_be_free
    return if TrainStops::WayCheckerService.call(station: station, train_stop: self).success?

    errors.add(:way_number, message: "#{way_number} занят")
  end
end
