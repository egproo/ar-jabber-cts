class Contract < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  scope :active, -> { where(active: true) }

  belongs_to :buyer, class_name: 'User', inverse_of: :bought_contracts
  belongs_to :seller, class_name: 'User', inverse_of: :sold_contracts
  has_many :payments, dependent: :destroy, inverse_of: :contract
  has_one :last_payment, class_name: 'Payment', order: 'effective_from DESC', inverse_of: :contract

  attr_accessible :name, :next_amount_estimate, :type, :active
  accepts_nested_attributes_for :buyer, :seller, :payments

  validates :name,
    uniqueness: {
      scope: :active,
      if: :active
    },
    presence: true,
    format: { with: /.@conference.syriatalk.biz\z/ }
  validates :type, presence: true
  validates :buyer, presence: true
  validates :seller, presence: true

  def next_payment_date
    last_payment.try(:effective_to)
  end

  def to_s
    name.sub('@conference.syriatalk.biz', '')
  end
end
