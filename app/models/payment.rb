class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :money_transfer, inverse_of: :payments
  belongs_to :contract, inverse_of: :payments

  attr_accessible :amount, :contract, :money_transfer, :effective_from
  accepts_nested_attributes_for :money_transfer, :contract

  validates :amount, inclusion: { in: (1..200), message: "from 1 to 200" }, presence: true
  validates :money_transfer, presence: true
  validates :contract, presence: true

  before_create :set_effective_from

  def to_s
    "$#{amount} for #{contract} at #{money_transfer.received_at.to_date}"
  end

  def set_effective_from
    self.effective_from = if next_payment_date = contract.next_payment_date
                            [money_transfer.received_at, next_payment_date].max
                          else
                            money_transfer.received_at
                          end
  end
end
