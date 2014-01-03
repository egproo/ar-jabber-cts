class CreateMoneyTransfers < ActiveRecord::Migration
  def change
    create_table :money_transfers do |t|
      t.references :sender
      t.references :receiver
      t.integer :amount
      t.string :comment

      t.timestamps
    end
    add_index :money_transfers, :sender_id
    add_index :money_transfers, :receiver_id
  end
end
