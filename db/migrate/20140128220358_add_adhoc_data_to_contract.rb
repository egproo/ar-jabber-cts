class AddAdhocDataToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :adhoc_data, :text
  end
end
