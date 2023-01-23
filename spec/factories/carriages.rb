FactoryBot.define do
  factory :carriage do
    name { Faker::Ancient.god }
    type { association(:carriage_type) }

    trait :carriage_with_seats do
      after :create do |carriage|
        carriage.capacity.times do |i|
          create(:seat, number: i, carriage_id: carriage.id)
        end
      end
    end
  end
end
