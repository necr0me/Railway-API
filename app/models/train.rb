class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify

  before_destroy { carriages.update(order_number: nil) }
end
