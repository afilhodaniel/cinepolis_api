class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name,                  null: false
      t.string :email,                 null: false
      t.string :password,              null: false
      t.string :access_token,          null: false
      t.string :facebook_id,           null: false
      t.string :facebook_access_token, null: false

      t.timestamps null: false
    end

    add_index :users, :email,                 unique: true
    add_index :users, :access_token,          unique: true
    add_index :users, :facebook_id,           unique: true
    add_index :users, :facebook_access_token, unique: true
  end
end
