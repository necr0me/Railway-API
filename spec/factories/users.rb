FactoryBot.define do
  factory :user do
    email { 'johndoe@gmail.com' }
    password { 'password' }
  end

  trait :with_refresh_token do
    after :create do |user|
      user.create_refresh_token(value: 'value')
    end
  end

  trait :with_profile do
    after :create do |user|
      create(:profile, user_id: user.id)
    end
  end
end
