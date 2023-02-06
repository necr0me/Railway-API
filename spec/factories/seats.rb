FactoryBot.define do
  factory :seat do
    is_taken { false }
    carriage { association(:carriage) }

    sequence(:number) do |n|
      rand(n..n + 30) - n + 1
    end
  end
end
