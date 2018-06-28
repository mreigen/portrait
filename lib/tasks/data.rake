namespace :data do
  task update_encrypted_passwords: :environment do
    include Authenticatable

    User.all.find_each do |user| # each in batches
      salt, password = Authenticatable.encrypt_password(user, user.password)

      user.update({
        encrypted_password: password,
        salt: salt
      })
    end
  end
end
