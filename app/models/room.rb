class Room < Contract
  before_save :normalize_name

  validates :name,
    uniqueness: {
      scope: :active,
      if: :active
    },
    presence: true,
    format: { with: /.@#{Regexp.escape(Ejabberd::DEFAULT_ROOMS_VHOST)}\z/ }
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

  attr_reader :occupants_number

  def last_message_at
    Integer === @last_message_at ?
      @last_message_at :
      @last_message_at = (Time.parse("#@last_message_at +0000").to_i rescue 0)
  end

  def deactivate(options = {})
    backup!
    self.active = false
    self.deactivated_at = Time.now
    self.deactivated_by = options[:deactivated_by]
    Ejabberd.new.room(name).destroy unless options[:server_destroy] == false
    self
  end

  def normalize_name
    name, host = self.name.split('@', 2)
    self.name = "#{name.nodeprep}@#{host.nameprep}"
  end
end
