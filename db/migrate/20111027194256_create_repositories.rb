class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      
      t.string :uid
      t.string :user_uid
      t.string :name
      t.text :description
      t.string :language
      t.integer :watchers
      t.integer :forks
      t.timestamps
    end
  end
end
