class Payment < ActiveRecord::Base
  belongs_to :money_transfer
  belongs_to :contract
  attr_accessible :amount

  def to_s
    "$#{amount} for #{contract} at #{created_at.to_date}"
  end
end
