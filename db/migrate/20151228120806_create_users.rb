class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.attachment :avatar
      t.string     :name,     null: false
      t.text       :bio
      t.string     :username
      t.string     :email,    null: false
      t.string     :password, null: false

      t.timestamps null: false
    end

    add_index :users, :username, unique: true
    add_index :users, :email,    unique: true
  end
end
