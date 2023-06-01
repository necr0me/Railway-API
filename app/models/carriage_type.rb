class CarriageType < ApplicationRecord
  has_many :carriages, dependent: :restrict_with_exception

  auto_strip_attributes :name, :description, squish: true

  validates :name, presence: true, length: { minimum: 3, maximum: 32 }
  validates :description, length: { maximum: 140 }
  validates :capacity, presence: true, comparison: { greater_than_or_equal_to: 0 }
  validates :cost_per_hour, presence: true, numericality: { only_float: true, greater_than: 0 }

  def self.search(term)
    where("LOWER(name) like :prefix", prefix: "#{term&.downcase}%")
  end
end
