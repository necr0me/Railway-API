FactoryBot.define do
  factory :station do
    name { "Melbourne" }
  end

  trait :station_sequence_with_name_list do
    transient { list { %w[Mogilev Mosty Minsk] } }
    sequence(:name, 0) { |n| list[n].to_s }
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

  trait :station_with_train_stops do
    after :create do |station|
      3.times do
        create(:train_stop, station_id: station.id)
      end
    end
  end
end
