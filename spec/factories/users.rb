FactoryBot.define do
  factory :user do
    name 'alibaba'
    password 'fortytheives'
    encrypted_password ''
    salt ''

    trait :admin do
      name 'admin'
      password 'password'
    end
  end
end