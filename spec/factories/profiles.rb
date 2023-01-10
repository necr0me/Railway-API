FactoryBot.define do
  factory :profile do
    name { "John" }
    surname { "Doe" }
    patronymic { "Doehovich" }
    phone_number { "+375337777777" }
    passport_code { "kh2321332" }
    user { association(:user) }
  end

  factory :blank_profile, class: Profile
end
