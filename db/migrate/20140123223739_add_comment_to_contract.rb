class AddCommentToContract < ActiveRecord::Migration
  def up
    add_column :contracts, :comment, :text
    change_column :money_transfers, :comment, :text
  end

  def down
    remove_column :contracts, :comment
    change_column :money_transfers, :comment, :string
  end
end
