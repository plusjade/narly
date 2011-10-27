class AddUserFields < ActiveRecord::Migration

  def change
    add_column :users, :username, :string
    add_column :users, :avatar_url, :string
    add_column :users, :email, :string
  end
end
