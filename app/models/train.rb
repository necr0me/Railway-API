class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify
  has_many :stops, class_name: "TrainStop", dependent: :destroy

  before_destroy { carriages.update(order_number: nil) }

  delegate :destination, to: :route, allow_nil: true

  def last_stop
    stops.where.not(id: nil)&.last
  end

  def travel_time
    stops.length <= 1 ? 0 : stops.last.arrival_time - stops.first.departure_time
  end

  def self.search(term)
    where(id: joins(:route).where("LOWER(destination) like :prefix", prefix: "#{term&.downcase}%").map(&:id))
  end
end
