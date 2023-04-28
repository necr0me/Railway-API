FactoryBot.define do
  factory :ticket do
    price { 1.5 }
    profile { Profile.first || association(:profile) }
    seat { Seat.first || association(:seat, is_taken: true) }
    arrival_station { Station.first || association(:station) }
    departure_station { Station.first || association(:station) }
  end
end
