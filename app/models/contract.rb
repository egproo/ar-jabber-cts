class Contract < ActiveRecord::Base
  audited

  serialize :adhoc_data

  scope :active, -> { where(active: true) }
  scope :sold_by, proc { |seller| seller.role >= User::ROLE_SUPER_MANAGER ? {} : where(seller_id: seller) }

  belongs_to :buyer, class_name: 'User', inverse_of: :bought_contracts, touch: true
  belongs_to :seller, class_name: 'User', inverse_of: :sold_contracts, touch: true
  has_many :payments, dependent: :destroy, inverse_of: :contract
  has_one :last_payment, class_name: 'Payment', order: 'effective_from DESC'

  attr_accessible :name, :next_amount_estimate, :type, :active, :comment
  accepts_nested_attributes_for :buyer, :seller, :payments

  validates :type, presence: true
  validates :buyer, presence: true
  validates :seller, presence: true

  def next_payment_date
    last_payment.try(:next_expected_date)
  end
end
