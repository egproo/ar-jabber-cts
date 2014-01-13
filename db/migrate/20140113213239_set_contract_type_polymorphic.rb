class SetContractTypePolymorphic < ActiveRecord::Migration
  def up
    change_column :contracts, :type, :string
    Contract.update_all(type: 'Room')
  end

  def down
    change_column :contracts, :type, :integer
    Contract.update_all(type: 1)
  end
end
