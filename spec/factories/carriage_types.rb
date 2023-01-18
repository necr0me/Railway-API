FactoryBot.define do
  factory :carriage_type do
    name { Faker::FunnyName.name }
    description { Faker::Company.name }
    capacity { 8 }
  end
end
