FactoryBot.define do
  factory :route do

    trait :with_stations do
      after :create do |route|
        create_list(:station, 3, :with_three_stations).each do |station|
          create(:station_order_number,
                 route_id: route.id,
                 station_id: station.id)
        end
      end
    end

    trait :with_many_stations do
      after :create do |route|
        create_list(:station, 100, :with_n_stations).each do |station|
          create(:station_order_number,
                 route_id: route.id,
                 station_id: station.id)
        end
      end
    end
  end
end
