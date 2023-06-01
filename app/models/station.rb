class Station < ApplicationRecord
  has_many :station_order_numbers, dependent: :delete_all
  has_many :routes, through: :station_order_numbers

  has_many :train_stops, class_name: "TrainStop", dependent: :destroy
  has_many :passing_trains, class_name: "Train", through: :train_stops

  auto_strip_attributes :name, squish: true

  validates :name,
            presence: true,
            length: { minimum: 2, maximum: 50 },
            uniqueness: true
  validates :number_of_ways,
            presence: true,
            comparison: { greater_than: 0 }

  def self.search(term)
    where("LOWER(name) like :prefix", prefix: "#{term&.downcase}%")
  end
end
