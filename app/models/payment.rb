class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :money_transfer, inverse_of: :payments
  belongs_to :contract, inverse_of: :payments

  attr_accessible :amount, :contract, :money_transfer, :effective_from, :effective_months
  accepts_nested_attributes_for :money_transfer, :contract

  before_validation :set_effective_from

  validates :amount, inclusion: { in: (1..200), message: "from 1 to 200" }, presence: true
  validates :money_transfer, presence: true
  validates :contract, presence: true
  validates :effective_months,
    presence: true,
    inclusion: { in: (1..12), message: "from 1 to 12" }
  validate :validate_not_overlaps

  def to_s
    "$#{amount} for #{contract} at #{money_transfer.received_at.to_date} " <<
      "(effective #{effective_from.try(:to_date)} .. #{effective_to.try(:to_date)})"
  end

  def effective_to
    if effective_from
      effective_months ? effective_from + effective_months.months - 1.day : effective_from
    else
      nil
    end
  end

  # Note: this method is not intended to be called twice
  def previous
    self.class.first(
      conditions: ['contract_id = ? AND id != ? AND effective_from <= ?', contract_id, id, effective_from],
      order: 'effective_from DESC',
    )
  end

  def siblings
    self.class.where(contract_id: contract_id)
  end

  def editable?
    contract.last_payment == self
  end

  def overlaps?
    return false unless effective_to = self.effective_to
    siblings.find { |p|
      p_effective_to = p.effective_to

      p.id != self.id &&
      p.effective_from &&
      ((
          p.effective_from >= effective_from &&
          p.effective_from <= effective_to
        ) || (
          p_effective_to >= effective_from &&
          p_effective_to <= effective_to
      ))
    }
  end

  def validate_not_overlaps
    return unless overlapper = overlaps?
    errors.add(:effective_from, "overlaps with #{overlapper}")
    errors.add(:effective_months, "overlaps with #{overlapper}")
  end

  def set_effective_from
    self.effective_from = if new_record?
                            # We cannot add new Payment between existing ones.
                            if next_payment_date = contract.next_payment_date
                              [money_transfer.received_at, next_payment_date].max
                            else
                              money_transfer.received_at
                            end
                          else
                            if previous_payment = self.previous
                              [previous_payment.effective_to + 1.day, money_transfer.received_at].max
                            else
                              money_transfer.received_at
                            end
                          end
  end
end
