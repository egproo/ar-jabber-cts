class Contract < ActiveRecord::Base
  TYPE_ROOM = 1
  TYPE_ANNOUNCEMENT = 2
  TYPE_SALARY = 3

  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  has_many :payments
  attr_accessible :name, :duration_months, :next_amount_estimate, :type

  validates_uniqueness_of :name

  self.inheritance_column = :_type_disabled

  def last_payment
    @last_payment ||= payments.last
  end

  def next_payment_date
    last_payment.try(:created_at).try(:+, duration_months.months)
  end

  def to_s
    name.sub('@conference.syriatalk.biz', '')
  end
end
