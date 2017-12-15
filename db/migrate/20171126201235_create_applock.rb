class CreateApplock < ActiveRecord::Migration[5.1]
  def change
  	create_table :applock, id: false do |t|
	  t.string :encrypted_password
	end
  end
end
