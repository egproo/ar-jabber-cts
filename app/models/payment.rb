class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :money_transfer
  belongs_to :contract
  attr_accessible :amount, :contract, :money_transfer

  validates :amount, inclusion: { in: (1..200), message: "from 1 to 200" }
  validates :amount, presence: true

  accepts_nested_attributes_for :money_transfer

  def to_s
    "$#{amount} for #{contract} at #{money_transfer.received_at.to_date}"
  end
end
