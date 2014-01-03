class User < ActiveRecord::Base
  ROLE_CLIENT = 0
  ROLE_MANAGER = 1
  ROLE_SUPER_MANAGER = 2
  ROLE_ADMIN = 3

  ROLE_NAMES = {
    ROLE_CLIENT => 'client',
    ROLE_MANAGER => 'manager',
    ROLE_SUPER_MANAGER => 'supervisor',
    ROLE_ADMIN => 'admin',
  }

  attr_accessible :jid, :name, :password, :phone, :role

  has_many :sent_transactions, class_name: 'Transaction', foreign_key: 'sender_id'
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'receiver_id'

  has_many :bought_contracts, class_name: 'Contract', foreign_key: 'buyer_id'
  has_many :sold_contracts, class_name: 'Contract', foreign_key: 'seller_id'

  def to_s
    "#{name} [#{ROLE_NAMES[role]}]#{" (JID/MAIL: #{jid})" if jid}#{" CELL #{phone}" if phone}"
  end
end
