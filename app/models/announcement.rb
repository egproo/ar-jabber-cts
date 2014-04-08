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

  def extract_room_names
    known_rooms = adhoc_data.scan(/\S+@#{Ejabberd::DEFAULT_ROOMS_VHOST}/)
    if known_rooms.present?
      known_rooms
    else
      adhoc_data.scan(/\S+@(?:chat|conference)\.\S+/)
    end.uniq
  end

  def to_s
    if (name = self.name).blank?
      name = extract_room_names.join(', ') || "#{adhoc_data[/\A\S+/]}..."
    end
    "announcement: #{name}"
  end
end
