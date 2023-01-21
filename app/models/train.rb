class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, -> { order(:order_number)}, dependent: :nullify
end
