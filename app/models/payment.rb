# encoding: utf-8

class Payment < ActiveRecord::Base
  belongs_to :money_transfer, inverse_of: :payments
  belongs_to :contract, inverse_of: :payments

  attr_accessible :amount, :contract, :money_transfer, :effective_from, :effective_months
  accepts_nested_attributes_for :money_transfer, :contract

  before_validation :set_effective_from

  validates :amount, inclusion: { in: (0..200), message: "from 0 to 200" }, presence: true
  validates :money_transfer, presence: true
  validates :contract, presence: true
  validates :effective_months,
    presence: true,
    inclusion: { in: (1..12), message: "from 1 to 12" }
  validate :validate_not_overlaps

  def to_s
    "$#{amount} for #{contract} at #{money_transfer.received_at.to_date} " <<
      "(effective #{effective_from.try(:to_date)} — #{effective_to.try(:to_date)})"
  end

  def effective_to
    if effective_from
      effective_months ? effective_from + effective_months.months - 1.day : effective_from
    else
      nil
    end
  end

  def next_expected_date
    effective_to.try(:+, 1.day)
  end

  # Note: this method is not intended to be called twice
  def previous
    self.class.first(
      conditions: ['contract_id = ? AND id != ? AND effective_from <= ?', contract_id, id, effective_from],
      order: 'effective_from DESC',
    )
  end

  def has_successor?
    if last_payment = contract.last_payment
      if new_record?
        last_payment.effective_to >= self.effective_from
      else
        last_payment != self
      end.tap do |result|
        logger.debug "Payment #{id}[#{self}] has a successor #{last_payment.id}[#{last_payment}]" if result
      end
    end
  end

  def overlapper
    return false unless effective_to = self.effective_to
    self.class.where(contract_id: contract_id).find { |p|
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

  private
  def validate_not_overlaps
    return unless overlapper = self.overlapper
    errors.add(:effective_from, "overlaps with #{overlapper}")
    errors.add(:effective_months, "overlaps with #{overlapper}")
  end

  def set_effective_from
    self.effective_from = if new_record?
                            contract.try(:next_payment_date)
                          else
                            # We cannot add new Payment between existing ones.
                            self.previous.try(:next_expected_date)
                          end

    if money_transfer.received_at
      if !self.effective_from || self.effective_from < money_transfer.received_at
        self.effective_from = money_transfer.received_at
      end
    end
  end
end
