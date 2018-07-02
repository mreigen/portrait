class AddEncryptedPasswordToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :encrypted_password, :string, default: '', null: false
    add_column :users, :salt, :string, default: '', null: false
  end
end
