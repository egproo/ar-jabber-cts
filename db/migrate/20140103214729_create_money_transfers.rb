class CreateMoneyTransfers < ActiveRecord::Migration
  def change
    create_table :money_transfers do |t|
      t.references :sender, null: false
      t.references :receiver, null: false
      t.integer :amount, null: false
      t.string :comment, null: true
      t.boolean :received, null: false, default: false

      t.timestamps
    end
    add_index :money_transfers, :sender_id
    add_index :money_transfers, :receiver_id
  end
end
