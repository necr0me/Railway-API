class Route < ApplicationRecord
  has_many :station_order_numbers, dependent: :delete_all
  has_many :stations, through: :station_order_numbers

  has_many :trains, dependent: :nullify

  def self.search(term, type: nil)
    return all if term.blank?

    if type&.to_sym == :advanced
      where(id: joins(:stations).where("LOWER(name) like :prefix", prefix: "#{term.downcase}%").uniq.map(&:id))
    else
      where("LOWER(destination) like :prefix", prefix: "#{term.downcase}%")
    end
  end
end
