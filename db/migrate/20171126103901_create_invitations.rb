class CreateInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :invitations do |t|
      t.string :token, unique: true
      t.string :user_type
      t.datetime :expiration_date
      t.integer :invited_by_id
      t.integer :used_by_id
    end
  end
end
