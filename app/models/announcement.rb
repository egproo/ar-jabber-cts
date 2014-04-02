class Announcement < Contract
  attr_accessible :adhoc_data
  validates :adhoc_data, presence: true

  scope :untracked, proc { |user|
    if user
      where(seller_id: user, buyer_id: user, active: false)
    else
      where('seller_id = buyer_id AND active = ?', false)
    end
  }

  def to_s
    "announcement: #{name}"
  end
end
