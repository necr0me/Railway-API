FactoryBot.define do
  factory :station do
    name { "Melbourne" }
  end

  trait :station_sequence_with_three_stations do
    list = %w[Mogilev Mosty Hrodna]
    sequence(:name) do |n|
      "#{list[(n - 1) % 3]}"
    end
  end

  trait :station_sequence_with_n_stations do
    sequence(:name) do |n|
      "station_#{n}"
    end
  end

  trait :station_with_route do
    after :create do |station|
      route = create(:route)
      create(:station_order_number,
             route_id: route.id,
             station_id: station.id)
    end
  end
end
