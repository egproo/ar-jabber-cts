class MoneyTransfer < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  has_many :payments
  attr_accessible :amount, :comment, :received
end
