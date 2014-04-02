class AddDeactivatedByToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :deactivated_by, :string, null: true
  end
end
