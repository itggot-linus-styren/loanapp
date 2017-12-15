class CreateHarddrives < ActiveRecord::Migration[5.1]
  def change
    create_table :harddrives do |t|
      t.string :name
      t.string :brand
      t.decimal :disksize
      t.string :status
      t.boolean :deleted
    end
  end
end
