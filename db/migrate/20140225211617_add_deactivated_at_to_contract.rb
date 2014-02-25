class AddDeactivatedAtToContract < ActiveRecord::Migration
  def up
    add_column :contracts, :deactivated_at, :datetime
  end

  def down
    remove_column :contracts, :deactivated_at
  end
end
