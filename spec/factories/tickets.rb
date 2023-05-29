FactoryBot.define do
  factory :ticket do
    price { 1.5 }
    profile { Profile.first || association(:profile) }
    seat { Seat.first || association(:seat, is_taken: true) }
    arrival_point { TrainStop.first || association(:train_stop) }
    departure_point { TrainStop.first || association(:train_stop) }
  end
end
