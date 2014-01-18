class AddEffectiveFromToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :effective_from, :datetime, null: true
    Payment.reset_column_information
    Payment.all(include: :money_transfer).each do |p|
      raise unless p.update_attribute(:effective_from, p.money_transfer.received_at)
    end
    change_column_null :payments, :effective_from, false
  end

  def down
    remove_column :payments, :effective_from
  end
end
