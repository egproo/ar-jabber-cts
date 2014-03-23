class Room < Contract
  before_save :normalize_name

  validates :name,
    uniqueness: {
      scope: :active,
      if: :active
    },
    presence: true,
    format: { with: /.@conference\.syriatalk\.biz\z/ }
  validates :name, uniqueness: { scope: [:buyer_id] }

  def to_s
    name.sub("@#{Ejabberd::DEFAULT_ROOMS_VHOST}", '')
  end

  def backup!
    self.adhoc_data = Ejabberd.new.room(name).info
  end

  def short_name
    name.sub(/@#{Ejabberd::DEFAULT_ROOMS_VHOST}\z/, '')
  end

  def short_name=
  end

  attr_reader :last_message_at

  def deactivate(server_destroy = true)
    backup!
    self.active = false
    self.deactivated_at = Time.now
    Ejabberd.new.room(name).destroy if server_destroy
    self
  end

  def normalize_name
    name, host = self.name.split('@', 2)
    self.name = "#{name.nodeprep}@#{host.nameprep}"
  end
end
