class StationOrderNumber < ApplicationRecord
  before_create :set_order_number!

  belongs_to :station
  belongs_to :route

  validates :order_number, comparison: { greater_than_or_equal_to: 1 }, on: :update

  default_scope -> { order(:order_number) }

  private

  def set_order_number!
    self.order_number = route.stations.count + 1
  end
end
