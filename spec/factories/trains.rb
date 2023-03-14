FactoryBot.define do
  factory :train do
    trait :train_with_carriages do
      after :create do |train|
        3.times do |i|
          carriage = create(:carriage,
                            train_id: train.id,
                            order_number: i + 1)
          carriage.capacity.times do |j|
            create(:seat,
                   carriage_id: carriage.id,
                   number: j + 1)
          end
        end
      end
    end

    trait :train_with_stops do
      after :create do |train|
        3.times do |i|
          create(:passing_train,
                 arrival_time: DateTime.now + i * 20.minutes,
                 departure_time: DateTime.now + (i + 1) * 20.minutes,
                 train_id: train.id)
        end
      end
    end

    trait :train_with_specific_stops do
      transient do
        stops_at { [] }
        start_time { DateTime.now }
        travel_time { 5 }
        stoppage_time { 5 }
      end

      after :create do |train, e|
        e.stops_at.each_with_index do |item, i|
          create(:passing_train,
                 arrival_time: e.start_time + i * (e.travel_time + e.stoppage_time).minutes,
                 departure_time: e.start_time + (i + 1) * (e.travel_time + e.stoppage_time).minutes,
                 station_id: item.id,
                 train_id: train.id)
        end
      end
    end
  end
end
