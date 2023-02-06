FactoryBot.define do
  factory :carriage do
    name { Faker::Ancient.god }
    type { association(:carriage_type) }

    sequence(:order_number) do |n|
      rand(n..n + 30) - n + 1
    end

    trait :carriage_with_seats do
      after :create do |carriage|
        carriage.capacity.times do |i|
          create(:seat, number: i + 1, carriage_id: carriage.id)
        end
      end
    end
  end
end
