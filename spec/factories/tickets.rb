FactoryBot.define do
  factory :ticket do
    price { 1.5 }
    user { User.first || association(:user) }
    seat { Seat.first || association(:seat, is_taken: true) }
    arrival_station { Station.first || association(:station) }
    departure_station { Station.first || association(:station) }
  end
end
