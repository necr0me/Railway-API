class Train < ApplicationRecord
  before_destroy :nullify_carriages_order_numbers!

  belongs_to :route, optional: true

  has_many :carriages, -> { order(:order_number)}, dependent: :nullify

  private

  def nullify_carriages_order_numbers!
    self.carriages.update_all(order_number: nil)
  end
end
