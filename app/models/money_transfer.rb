class MoneyTransfer < ActiveRecord::Base
  include Trackable

  belongs_to :sender, class_name: 'User', inverse_of: :sent_transfers
  belongs_to :receiver, class_name: 'User', inverse_of: :received_transfers
  has_many :payments, dependent: :destroy, inverse_of: :money_transfer

  attr_accessible :amount, :comment, :received_at, :sender, :receiver
  accepts_nested_attributes_for :payments

  validates :amount, presence: true, inclusion: { in: (1..5000), message: "from 1 to 5000" }
  validates :sender, presence: true
  validates :receiver, presence: true
  validates :received_at, presence: true
  validate :validate_payment_amounts
  validate :validate_received_at

  def to_s
    "#{sender.try(:name)} -> #{receiver.try(:name)} $#{amount} at #{received_at.try(:to_date)}"
  end

  def validate_payment_amounts
    return unless amount.present?
    # to_a to use real values instead of DB
    payments_sum = payments.to_a.sum(&:amount)
    errors.add(:amount, "is smaller than total payments amount #{payments_sum}") if payments_sum > amount
  rescue
    errors.add(:amount, 'may not be counted')
  end

  def validate_received_at
    return unless received_at.present?

    errors.add(:received_at, 'is in future') if received_at > 1.day.from_now # TODO: fix time zone issues

    if new_record? or received_at_changed?
      payments.each do |p|
        last_mt = p.contract.last_payment.try(:money_transfer)
        if last_mt && last_mt != self && last_mt.received_at >= self.received_at
          if new_record?
            errors.add(:received_at, "is before an existing money transfer (#{last_mt.received_at.to_date}) for #{p.contract.name}")
          else
            # Otherwise MT may be pushed in front forever
            errors.add(:received_at, "is superceded by another money transfer and cannot be changed (was #{received_at_was.to_date})")
          end
          break
        end
      end
    end
  end
end
