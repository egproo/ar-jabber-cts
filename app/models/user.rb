class User < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  STUB_NAME = 'stub'

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
    ROLE_STUB => 'stub',
    ROLE_CLIENT => 'client',
    ROLE_MINI_MANAGER => 'manager',
    ROLE_MANAGER => 'manager',
    ROLE_SUPER_MANAGER => 'supervisor',
    ROLE_ADMIN => 'admin',
  }

  attr_accessible :jid, :name, :password, :phone, :role, :locale

  has_many :sent_transfers, class_name: 'MoneyTransfer', foreign_key: 'sender_id'
  has_many :received_transfers, class_name: 'MoneyTransfer', foreign_key: 'receiver_id'

  has_many :bought_contracts, class_name: 'Contract', foreign_key: 'buyer_id'
  has_many :sold_contracts, class_name: 'Contract', foreign_key: 'seller_id'

  has_one :salary_contract, class_name: 'Contract', foreign_key: 'seller_id', conditions: { type: 'Salary' }

  validates :jid, format: { with: /\A.+@.+\z/ }
  validates :phone, format: { with: /\A\+?\d{8,15}\z/, if: 'phone.present?', message: "from 8 to 15" }
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :jid, presence: true

  def debt
    return 0 if role <= ROLE_CLIENT

    # Total received
    MoneyTransfer.all(conditions: { receiver_id: self }).sum(&:amount) -
    # Minus total sent
    MoneyTransfer.all(conditions: { sender_id: self }).sum(&:amount) -
    # Minus salary payoffs
    Payment.all(joins: :contract, conditions: { contracts: { type: 'Salary', seller_id: self } }).sum(&:amount)
  end

  def inspect
    "#{name} [#{role_name}]#{" (JID/MAIL: #{jid})" if jid}#{" CELL #{phone}" if phone}"
  end

  def to_s
    name
  end

  def role_name
    ROLE_NAMES[role]
  end

  def clients
    User.all(
      joins: :bought_contracts,
      conditions: {
        contracts: {
          type: ['Room', 'Announcement'],
          seller_id: self
        }
      })
  end

  def self.dump_htpasswd
    File.open(File.join(Rails.root, '.htpasswd'), 'w') do |htaccess|
      User.all(conditions: 'password IS NOT NULL').each do |user|
        htaccess.puts "#{user.name}:{PLAIN}#{user.password}"
      end
    end
  end

  after_save { User.dump_htpasswd }
end
