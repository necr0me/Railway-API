FactoryBot.define do
  factory :profile do
    name { "John" }
    surname { "Doe" }
    patronymic { "Doehovich" }
    phone_number { "+375331234567" }
    passport_code { "kh1234567" }
    user { association(:user) }
  end

  factory :blank_profile, class: "Profile"
end
