class AddReceivedAtToMoneyTransfers < ActiveRecord::Migration
  def up
    add_column :money_transfers, :received_at, :datetime
    MoneyTransfer.reset_column_information
    MoneyTransfer.update_all('received_at = created_at')
  end
  
  def down
    remove_column :money_transfers, :received_at
  end
end
