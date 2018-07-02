FactoryBot.define do
  factory :user do
    name 'alibaba'
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