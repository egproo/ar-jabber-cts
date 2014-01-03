class Payment < ActiveRecord::Base
  belongs_to :money_transfer
  belongs_to :contract
  attr_accessible :amount
end
