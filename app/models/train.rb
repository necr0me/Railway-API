class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify
  has_many :stops, class_name: "TrainStop", dependent: :destroy

  before_destroy { carriages.update(order_number: nil) }

  delegate :destination, to: :route, allow_nil: true

  def first_stop
    stops.where.not(id: nil)&.first
  end

  def last_stop
    stops.where.not(id: nil)&.last
  end

  def travel_time
    stops.length <= 1 ? 0 : stops.last.arrival_time - stops.first.departure_time
  end

  def self.search(term)
    return all if term.blank?

    where(id: joins(:route).where("LOWER(destination) like :prefix", prefix: "#{term.downcase}%").map(&:id))
  end

  def amount_of_free_seats
    carriages.inject(0) { |sum, carriage| sum + carriage.amount_of_free_seats }
  end

  def free?
    amount_of_free_seats.positive?
  end

  def travels?
    stops.count > 1
  end
end
