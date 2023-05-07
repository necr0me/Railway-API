FactoryBot.define do
  factory :train_stop do
    departure_time { DateTime.now + 20.minutes }
    arrival_time { DateTime.now }
    way_number { 1 }
    station { Station.first || association(:station) }
    train { Train.first || association(:train) }
  end
end
