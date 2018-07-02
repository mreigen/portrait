class AddPasswordResetFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :email, :string
    add_column :users, :reset_password_token, :string
    add_index  :users, :reset_password_token
  end
end
