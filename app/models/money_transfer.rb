class MoneyTransfer < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  has_many :payments, dependent: :destroy
  attr_accessible :amount, :comment, :received, :created_at

  validates_inclusion_of :amount, in: 1..5000
  validates_presence_of :sender, :receiver, :amount
  validates_presence_of :created_at

  validate :validate_payment_amounts

  def to_s
    "#{sender.name} -> #{receiver.name} $#{amount} at #{created_at.to_date}"
  end

  def validate_payment_amounts
    return unless amount.present?
    payments_sum = payments.inject(0) { |a,e| a + e.amount }
    errors.add(:amount, "is smaller than total payments amount #{payments_sum}") if payments_sum > amount
  end
end
