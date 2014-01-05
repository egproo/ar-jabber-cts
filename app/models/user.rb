class User < ActiveRecord::Base
  ROLE_STUB = -1
  ROLE_CLIENT = 0

  ROLE_MINI_MANAGER = 1

  ROLE_MANAGER = 2
  # ROLE_MINI_MANAGER +
  # Add Contract (seller = self, type = Room)
  # Add MoneyTransfer (receiver = self, sender = User.where(has contracts by self))
  #   immediately split into Payments (contract = Contract.where(seller = self))
  #     update contract_duration?
  # Add MoneyTransfer (sender = self, receiver = User.where(role >= ROLE_MINI_MANAGER))
  #   immediately create Payment (contract = 

  ROLE_SUPER_MANAGER = 3

  ROLE_ADMIN = 4


  ROLE_NAMES = {
    ROLE_CLIENT => 'client',
    ROLE_MANAGER => 'manager',
    ROLE_SUPER_MANAGER => 'supervisor',
    ROLE_ADMIN => 'admin',
  }

  attr_accessible :jid, :name, :password, :phone, :role, :locale

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: 'sender_id'
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'receiver_id'

  has_many :bought_contracts, class_name: 'Contract', foreign_key: 'buyer_id'
  has_many :sold_contracts, class_name: 'Contract', foreign_key: 'seller_id'

  def balance
    # transfers received with contract type = (ROOM, ANNOUNCEMENT)
  end

  def to_s
    "#{name} [#{ROLE_NAMES[role]}]#{" (JID/MAIL: #{jid})" if jid}#{" CELL #{phone}" if phone}"
  end
end
