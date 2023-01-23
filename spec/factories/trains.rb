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
  end
end
