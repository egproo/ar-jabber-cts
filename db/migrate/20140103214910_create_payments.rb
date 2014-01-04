class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :money_transfer, null: false
      t.integer :amount, null: false
      t.references :contract, null: false

      t.timestamps
    end
    add_index :payments, :money_transfer_id
    add_index :payments, :contract_id
  end
end
