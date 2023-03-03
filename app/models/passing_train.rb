class PassingTrain < ApplicationRecord
  belongs_to :train, inverse_of: :stops
  belongs_to :station, inverse_of: :passing_trains

  validate :arrival_cannot_be_later_than_departure

  private

  def arrival_cannot_be_later_than_departure
    if departure_time < arrival_time
      errors.add(:departure_time, "can't be greater than arrival time")
    end
  end
end
