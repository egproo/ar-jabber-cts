class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :name
      t.references :buyer
      t.references :seller
      t.integer :duration_months
      t.integer :next_amount_estimate

      t.timestamps
    end
    add_index :contracts, :buyer_id
    add_index :contracts, :seller_id
  end
end
