class Carriage < ApplicationRecord
  belongs_to :train, optional: true
  belongs_to :type, class_name: "CarriageType", foreign_key: :carriage_type_id,
                    inverse_of: :carriages
  has_many :seats, dependent: :delete_all

  default_scope -> { order(order_number: :asc) }

  auto_strip_attributes :name, squish: true

  validates :name, presence: true, length: { minimum: 3, maximum: 32 }
  validates :order_number, allow_nil: true, comparison: { greater_than_or_equal_to: 1 }

  delegate :capacity, to: :type

  def amount_of_free_seats
    seats.where(is_taken: false).count
  end

  def self.search(term)
    where("LOWER(name) like :prefix", prefix: "#{term&.downcase}%")
  end
end
