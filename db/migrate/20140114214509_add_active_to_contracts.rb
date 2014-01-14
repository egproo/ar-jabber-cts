class AddActiveToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :active, :boolean, null: false, default: true
  end
end
