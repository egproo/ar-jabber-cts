class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :money_transfer
      t.integer :amount
      t.references :contract

      t.timestamps
    end
    add_index :payments, :money_transfer_id
    add_index :payments, :contract_id
  end
end
