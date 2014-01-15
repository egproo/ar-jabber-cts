class Contract < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  default_scope where(active: true)

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  has_many :payments, dependent: :destroy
  has_one :last_payment, class_name: 'Payment', order: 'created_at DESC'
  attr_accessible :name, :duration_months, :next_amount_estimate, :type, :active

  accepts_nested_attributes_for :buyer, :seller, :payments

  validates :name, uniqueness: true
  validates :type, presence: true
  validates :buyer, presence: true
  validates :seller, presence: true
  validates :name, presence: true
  validates :name, format: { with: /.@conference.syriatalk.biz\z/ }
  validates :duration_months, presence: true
  validates :duration_months, inclusion: { in: (1..12), message: "from 1 to 12" }

  def next_payment_date
    last_payment.try(:money_transfer).try(:received_at).try(:+, duration_months.months) if duration_months
  end

  def to_s
    name.sub('@conference.syriatalk.biz', '')
  end
end
