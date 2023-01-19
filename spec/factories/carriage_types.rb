FactoryBot.define do
  factory :carriage_type do
    name { Faker::FunnyName.name }
    description { Faker::Company.name }
    capacity { 8 }

    trait :type_with_carriage do
      after :create do |carriage_type|
        create(:carriage,
               name: Faker::Ancient.god,
               carriage_type_id:  carriage_type.id)
      end
    end
  end
end
