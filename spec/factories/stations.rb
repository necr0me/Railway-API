FactoryBot.define do
  factory :station do
    name { "Melbourne" }
  end

  trait :with_three_stations do
    list = %w[Mogilev Mosty Hrodna]
    sequence(:name) do |n|
      "#{list[(n - 1) % 3]}"
    end
  end
end
