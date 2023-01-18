FactoryBot.define do
  factory :seat do
    number { "MyString" }
    is_taken { false }
    carriage { nil }
  end
end
