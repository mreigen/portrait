FactoryBot.define do
  sequence :name do |n|
    "user_#{n}"
  end

  factory :user do
    name
    password 'fortytheives'
    encrypted_password ''
    salt ''
    email 'some_email@gmail.com'
    reset_password_token 'abc'

    trait :admin do
      name 'admin'
      password 'password'
    end
  end
end