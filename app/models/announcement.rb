class Announcement < Contract

  has_and_belongs_to_many :rooms

  DEFAULT_ANNOUNCEMENT_COST = 5
  FIRST_ANNOUNCEMENT_COST = 0

  attr_accessible :adhoc_data
  validates :adhoc_data, presence: true

  validate :all_rooms_have_the_same_owner, on: :create

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

    amount = room_and_cost

    payments.build(
      amount: amount,
      effective_months: 1,
    ).tap do |p|
      p.build_money_transfer(
        amount: amount,
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

  def room_and_cost
    # Add announcement to room
    # and return cost if there were no rooms with the same name in the database
    # and room is active
    # and there were no room announcements before
    if (rooms = Room.where(name: room_names)).size == 1 && rooms.first.active && rooms.first.announcements.empty?
      self.rooms << rooms.first
      return FIRST_ANNOUNCEMENT_COST
    else
      return DEFAULT_ANNOUNCEMENT_COST
    end
  end

  private

  def all_rooms_have_the_same_owner
    errors.add(:adhoc_data, "All rooms should have the same owner") unless guess_buyers.size == 1
  end
end
