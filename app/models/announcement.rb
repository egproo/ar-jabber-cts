class Announcement < Contract
  attr_accessible :adhoc_data
  validates :adhoc_data, presence: true

  def to_s
    name
  end
end
