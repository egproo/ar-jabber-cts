class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :money_transfer, inverse_of: :payments
  belongs_to :contract, inverse_of: :payments

  attr_accessible :amount, :contract, :money_transfer, :effective_from, :effective_months
  accepts_nested_attributes_for :money_transfer, :contract

  validates :amount, inclusion: { in: (1..200), message: "from 1 to 200" }, presence: true
  validates :money_transfer, presence: true
  validates :contract, presence: true
  validates :effective_months,
    presence: true,
    inclusion: { in: (1..12), message: "from 1 to 12" }

  before_save :set_effective_from

  def to_s
    "$#{amount} for #{contract} at #{money_transfer.received_at.to_date}"
  end

  def effective_to
    effective_from + effective_months.months if effective_from && effective_months
  end

  # Note: this method is not intended to be called twice
  def previous
    self.class.first(
      conditions: ['contract_id = ? AND id != ? AND effective_from <= ?', contract_id, id, effective_from],
      order: 'effective_from DESC',
    )
  end

  def editable?
    contract.last_payment == self
  end

  def set_effective_from
    self.effective_from = if new_record?
                            if next_payment_date = contract.next_payment_date
                              [money_transfer.received_at, next_payment_date].max
                            else
                              money_transfer.received_at
                            end
                          else
                            if previous_payment = self.previous
                              [previous_payment.effective_to, money_transfer.received_at].max
                            else
                              money_transfer.received_at
                            end
                          end
  end
end
