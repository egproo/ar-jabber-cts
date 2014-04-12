class User < ActiveRecord::Base
  before_validation :normalize_jid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable

  attr_accessible :jid, :password, :password_confirmation, :remember_me, :phone, :role, :locale

  audited

  def serializable_hash(options = nil)
    # Devise gives us a very unpleasant performance drop here (about 7 times).
    # lib/devise/models/authenticatable.rb:104
    # We work around this by reimplementing this method.
    {
      id: self.id,
      role: self.role,
      phone: self.phone,
      jid: self.jid,
      created_at: self.created_at,
    }
  end

  STUB_NAME = 'sa'

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

  has_many :sent_transfers, class_name: 'MoneyTransfer', foreign_key: 'sender_id'
  has_many :received_transfers, class_name: 'MoneyTransfer', foreign_key: 'receiver_id'
  has_many :bought_contracts, class_name: 'Contract', foreign_key: 'buyer_id'
  has_many :sold_contracts, class_name: 'Contract', foreign_key: 'seller_id'
  has_one :salary_contract, class_name: 'Contract', foreign_key: 'seller_id', conditions: { type: 'Salary' }

  validates :jid, format: { with: /@/ }, presence: true, uniqueness: true
  validates :phone, format: { with: /\A\+?\d{8,15}\z/, if: 'phone.present?', message: "from 8 to 15" }

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
    "#{jid} [#{role_name}]#{" CELL #{phone}" if phone}"
  end

  def to_s
    jid
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
      },
      group: 'users.jid')
  end

  def normalize_jid
    name, host = self.jid.split('@', 2)
    self.jid = "#{name.nodeprep}@#{host.nameprep}"
  end
end
