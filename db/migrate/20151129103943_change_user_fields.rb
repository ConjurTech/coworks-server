class ChangeUserFields < ActiveRecord::Migration
  def change
    add_index :users, :confirmation_token,   :unique => true
    rename_column :users, :nickname, :username
    remove_column :users, :image
  end
end
