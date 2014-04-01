class Announcement < Contract
  attr_accessible :adhoc_data
  validates :adhoc_data, presence: true

  scope :untracked, lambda { |user|
    {
      conditions: {
        seller_id: user,
        buyer_id: user,
        active: false,
      }
    }
  }

  def to_s
    "announcement: #{name}"
  end
end
