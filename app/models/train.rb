class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify
  has_many :stops, class_name: "TrainStop", dependent: :destroy

  before_destroy { carriages.update(order_number: nil) }

  delegate :destination, to: :route, allow_nil: true

  def last_stop
    stops.where.not(id: nil)&.last
  end
end
