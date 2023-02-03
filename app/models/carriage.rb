class Carriage < ApplicationRecord
  belongs_to :train, optional: true
  belongs_to :type, class_name: 'CarriageType', foreign_key: :carriage_type_id
  has_many :seats, -> { order(number: :asc) }, dependent: :destroy

  auto_strip_attributes :name, squish: true

  validates :name, presence: true, length: { minimum: 3, maximum: 32 }
  validates :order_number, allow_nil: true, comparison: { greater_than_or_equal_to: 1 }

  def capacity
    self.type.capacity
  end
end
