class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name,         null: false
      t.string :email,        null: false
      t.string :password,     null: false
      t.string :access_token, null: false

      t.timestamps null: false
    end

    add_index :users, :email,    unique: true
  end
end
