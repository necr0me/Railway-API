FactoryBot.define do
  factory :profile do
    name { "John" }
    surname { "Doe" }
    patronymic { "Doehovich" }
    phone_number { "+375331234567" }
    passport_code { "kh1234567" }
    user { User.first || association(:user) }
  end

  trait :profile_with_ticket do
    after :create do |profile|
      create(:ticket, profile: profile)
    end
  end

  factory :blank_profile, class: "Profile"
end
