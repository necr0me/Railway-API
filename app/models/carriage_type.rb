class CarriageType < ApplicationRecord
  has_many :carriages, dependent: :restrict_with_exception

  auto_strip_attributes :name, :description, squish: true

  validates :name, presence: true, length: { minimum: 3, maximum: 32 }
  validates :description, length: { maximum: 140 }
  validates :capacity, presence: true, comparison: { greater_than_or_equal_to: 0, less_than: 55 }
  validates :cost_per_hour, presence: true, numericality: { only_float: true, greater_than: 0 }

  validate :capacity_must_be_dividable

  DIVISION_NUMBERS = {
    "Спальный вагон": 2,
    "Купе": 4,
    "Плацкарт": 6
  }.freeze

  def self.search(term)
    where("LOWER(name) like :prefix", prefix: "#{term&.downcase}%")
  end

  def capacity_must_be_dividable
    return unless DIVISION_NUMBERS[name.to_sym].present? && capacity % DIVISION_NUMBERS[name.to_sym] != 0

    errors.add(:capacity, "должна быть кратной #{DIVISION_NUMBERS[name.to_sym]} для типа \"#{name}\"")
  end
end
