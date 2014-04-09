class MoneyTransfer < ActiveRecord::Base
  audited

  scope :received_by, proc { |receiver| receiver.role >= User::ROLE_SUPER_MANAGER ? {} : where(receiver_id: receiver) }

  belongs_to :sender, class_name: 'User', inverse_of: :sent_transfers, touch: true
  belongs_to :receiver, class_name: 'User', inverse_of: :received_transfers, touch: true
  has_many :payments, dependent: :destroy, inverse_of: :money_transfer

  attr_accessible :amount, :comment, :received_at, :sender, :receiver
  accepts_nested_attributes_for :payments

  validates :amount, presence: true, inclusion: { in: (0..5000), message: "from 0 to 5000" }
  validates :sender, presence: true
  validates :receiver, presence: true
  validates :received_at, presence: true
  validate :validate_payment_amounts
  validate :validate_received_at

  def to_s
    "#{sender.try(:name)} -> #{receiver.try(:name)} $#{amount} at #{received_at.try(:to_date)}"
  end

  def readonly?
    @readonly = !new_record? && !!payments.any?(&:has_successor?)
  end

  def validate_payment_amounts
    return unless amount.present?
    # to_a to use real values instead of DB
    payments_sum = payments.to_a.sum(&:amount)
    # TODO: allow Manager+ to receive MT w/o payments
    errors.add(:amount, "is not the same as total payments amount #{payments_sum}") if payments_sum != amount
  rescue
    errors.add(:amount, 'may not be counted')
  end

  def validate_received_at
    return unless received_at.present?

    errors.add(:received_at, 'is in future') if received_at > 1.day.from_now # TODO: fix time zone issues

    if new_record? or received_at_changed?
      payments.each do |p|
        last_mt = p.contract.payments.map(&:money_transfer).sort_by(&:received_at).select { |mt| mt.id != self.id }.last
        if last_mt && last_mt.received_at >= self.received_at
          if new_record?
            errors.add(:received_at, "is before an existing money transfer (#{last_mt.received_at.to_date}) for #{p.contract.name}")
          else
            # Otherwise MT may be pushed in front forever
            errors.add(:received_at, "is superseded by another money transfer (#{last_mt.id} #{last_mt.received_at.to_date}) " <<
                       "and cannot be changed (was #{received_at_was.to_date})")
          end
          break
        end
      end
    end
  end
end
