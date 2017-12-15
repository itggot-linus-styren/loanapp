class CreateCars < ActiveRecord::Migration[5.1]
  def change
    create_table :cars do |t|
      t.string :name
      t.string :brand
      t.string :status
      t.boolean :deleted
    end
  end
end
