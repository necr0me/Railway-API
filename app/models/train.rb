class Train < ApplicationRecord
  belongs_to :route, optional: true

  has_many :carriages, dependent: :nullify
  has_many :stops, class_name: 'PassingTrain', dependent: :delete_all

  before_destroy { carriages.update(order_number: nil) }
end
