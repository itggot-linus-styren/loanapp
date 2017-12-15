class CreateUsers < ActiveRecord::Migration[5.1]
  def change
  	create_table :users do |t|
      t.string :username
      t.string :user_type
      t.string :encrypted_password
      t.datetime :registred_at
    end
  end
end
