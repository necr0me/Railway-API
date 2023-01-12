class StationOrderNumber < ApplicationRecord
  before_create :set_order_number!

  belongs_to :station
  belongs_to :route

  default_scope -> { order(:order_number) }

  private

  def set_order_number!
    self.order_number = route.stations.count + 1
  end
end
