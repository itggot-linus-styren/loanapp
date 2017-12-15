class CreateLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :loans do |t|
      t.references :loanable, polymorphic: true, index: true
      t.string :responsible
      t.string :purpose
      t.string :location
      t.datetime :loaned_at
      t.datetime :returned_at
    end
  end
end
