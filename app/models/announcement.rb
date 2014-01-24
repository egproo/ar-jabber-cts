class Announcement < Contract
  validates :comment, presence: true
end
