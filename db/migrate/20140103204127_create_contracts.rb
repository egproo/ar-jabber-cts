class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :name, null: false
      t.references :buyer, null: false
      t.references :seller, null: false
      t.integer :duration_months, null: false
      t.integer :next_amount_estimate, null: true

      t.timestamps
    end
    add_index :contracts, :buyer_id
    add_index :contracts, :seller_id
  end
end
