class Station < ApplicationRecord
  auto_strip_attributes :name, squish: true

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 50},
            uniqueness: true
end
