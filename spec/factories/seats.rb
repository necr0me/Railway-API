FactoryBot.define do
  factory :seat do
    number { 1 }
    is_taken { false }
    carriage { association(:carriage) }
  end
end
