FactoryBot.define do
  factory :route do
    trait :route_with_stations do
      after :create do |route|
        create_list(:station, 3, :station_sequence_with_name_list).each do |station|
          create(:station_order_number,
                 route_id: route.id,
                 station_id: station.id)
        end
      end
    end

    trait :route_with_many_stations do
      after :create do |route|
        create_list(:station, 20, :station_sequence_with_n_stations).each do |station|
          create(:station_order_number,
                 route_id: route.id,
                 station_id: station.id)
        end
      end
    end

    trait :route_with_trains do
      after :create do |route|
        3.times do
          create(:train,
                 route_id: route.id)
        end
      end
    end
  end
end
