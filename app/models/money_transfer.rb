class MoneyTransfer < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :sender, class_name: 'User', inverse_of: :sent_transfers
  belongs_to :receiver, class_name: 'User', inverse_of: :received_transfers
  has_many :payments, dependent: :destroy, inverse_of: :money_transfer

  attr_accessible :amount, :comment, :received, :received_at, :sender, :receiver
  accepts_nested_attributes_for :payments

  validates :amount, presence: true, inclusion: { in: (1..5000), message: "from 1 to 5000" }
  validates :sender, presence: true
  validates :receiver, presence: true
  validates :received_at, presence: true
  validate :validate_payment_amounts

  def to_s
    "#{sender.try(:name)} -> #{receiver.try(:name)} $#{amount} at #{created_at.try(:to_date)}"
  end

  def validate_payment_amounts
    return unless amount.present?
    payments_sum = payments.sum(&:amount)
    errors.add(:amount, "is smaller than total payments amount #{payments_sum}") if payments_sum > amount
  end
end
