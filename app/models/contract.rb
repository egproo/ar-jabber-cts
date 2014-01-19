class Contract < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  scope :active, -> { where(active: true) }

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  has_many :payments, dependent: :destroy
  has_one :last_payment, class_name: 'Payment', order: 'effective_from DESC'
  attr_accessible :name, :duration_months, :next_amount_estimate, :type, :active

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
  validates :duration_months,
    presence: true,
    inclusion: { in: (1..12), message: "from 1 to 12" }

  def next_payment_date
    last_payment.try(:effective_from).try(:+, duration_months.months) if duration_months
  end

  def to_s
    name.sub('@conference.syriatalk.biz', '')
  end
end
