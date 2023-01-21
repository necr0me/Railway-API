FactoryBot.define do
  factory :train do
    trait :train_with_carriages do
      after :create do |train|
        3.times do |i|
          create(:carriage,
                 train_id: train.id,
                 order_number: i + 1)
        end
      end
    end
  end
end
