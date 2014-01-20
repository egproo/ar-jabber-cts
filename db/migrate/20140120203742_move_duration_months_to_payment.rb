class MoveDurationMonthsToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :effective_months, :integer, null: true
    Payment.reset_column_information
    Payment.update_all(effective_months: 0)
    Contract.all(include: :last_payment).each do |c|
      last_payment = c.last_payment
      next unless last_payment

      last_payment.effective_months = c.duration_months
      last_payment.save!(validate: false)

      if previous_payment = last_payment.previous
        months = ((last_payment.effective_from - previous_payment.effective_from) / 32.0).ceil
        if months >= 0
          previous_payment.effective_months = months
          previous_payment.save!(validate: false)
        else
          say "Payment #{previous_payment} will have negative effective months value: #{months}"
        end
      end
    end
    remove_column :contracts, :duration_months
  end

  def down
    add_column :contracts, :duration_months, :integer
    Contract.all(include: :last_payment).each do |c|
      next unless c.last_payment
      c.duration_months = c.last_payment.effective_months
      c.save!(validate: false)
    end
    remove_column :payments, :effective_months
  end
end
