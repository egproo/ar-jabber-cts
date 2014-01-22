class RemoveReceivedFromMoneyTransfer < ActiveRecord::Migration
  def up
    remove_column :money_transfers, :received
  end

  def down
    add_column :money_transfers, :received, :boolean, default: false
  end
end
