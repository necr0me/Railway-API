FactoryBot.define do
  factory :seat do
    is_taken { false }
    carriage { association(:carriage) }

    sequence(:number) do |n|
      rand(n..n + 30) - n + 1
    end

    trait :seat_with_ticket do
      after :create do |seat|
        create(:ticket, seat: seat)
      end
    end
  end
end
