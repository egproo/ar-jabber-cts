class Announcement < Contract

  has_and_belongs_to_many :rooms

  DEFAULT_COST = 5

  attr_accessible :adhoc_data
  validates :adhoc_data, presence: true

  scope :untracked, proc { |user|
    conditions = {
      payments: { contract_id: nil }
    }
    if user
      conditions[:seller_id] = user
    end
    includes(:payments).where(conditions)
  }

  def room_names
    known_rooms = adhoc_data.scan(/\S+@#{Ejabberd::DEFAULT_ROOMS_VHOST}/)
    if known_rooms.present?
      known_rooms
    else
      adhoc_data.scan(/\S+@(?:chat|conference)\.\S+/)
    end.uniq
  end

  def guess_buyers
    Room.
      active.
      accessible_by(Ability.new(seller)).
      where(name: room_names).
      includes(:buyer).
      map(&:buyer).
      uniq
  end

  def autotrack
    return if ((buyers = guess_buyers).size != 1) ||
      payments.any? ||
      active

    self.buyer = buyers.first

    payments.build(
      amount: DEFAULT_COST,
      effective_months: 1,
    ).tap do |p|
      p.build_money_transfer(
        amount: DEFAULT_COST,
        received_at: Time.now.to_date,
        sender: buyer,
        receiver: seller,
        payments: [p],
      )
      self.active = true
    end
  end

  def to_s
    if (name = self.name).blank?
      name = room_names.join(', ') || "#{adhoc_data[/\A\S+/]}..."
    end
    "announcement: #{name}"
  end
end
