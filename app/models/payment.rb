class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :money_transfer
  belongs_to :contract
  attr_accessible :amount, :contract
  validates_inclusion_of :amount, in: (1..200)
  validates_presence_of :amount

  def to_s
    "$#{amount} for #{contract} at #{created_at.to_date}"
  end
end
