class Contract < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.try(:current_user) }

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  has_many :payments
  has_one :last_payment, class_name: 'Payment', order: 'created_at DESC'
  attr_accessible :name, :duration_months, :next_amount_estimate, :type

  accepts_nested_attributes_for :buyer, :seller, :payments

  validates_uniqueness_of :name
  validates_presence_of :type
  validates_presence_of :buyer
  validates_presence_of :seller
  validates_format_of :name, with: /.@conference.syriatalk.biz\z/
  validates_presence_of :duration_months

  def next_payment_date
    last_payment.try(:created_at).try(:+, duration_months.months) if duration_months
  end

  def to_s
    name.sub('@conference.syriatalk.biz', '')
  end
end
