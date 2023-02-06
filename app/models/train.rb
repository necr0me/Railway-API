class Train < ApplicationRecord
  before_destroy :nullify_carriages_order_numbers!

  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify

  private

  def nullify_carriages_order_numbers!
    carriages.update(order_number: nil)
  end
end
