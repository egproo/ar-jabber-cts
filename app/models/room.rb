class Room < Contract

  has_and_belongs_to_many :announcements

  before_validation :normalize_name

  validates :name,
    uniqueness: {
      scope: :active,
      if: :active
    },
    presence: true,
    format: { with: /.@#{Regexp.escape(Ejabberd::DEFAULT_ROOMS_VHOST)}\z/ }
  validates :name, uniqueness: { scope: [:buyer_id] }

  after_validation :copy_errors_to_short_name

  def to_s
    short_name
  end

  def backup!
    data = Ejabberd.new.room(name).info
    if Hash === data
      data['dumped_at'] = Time.now.utc
      self.adhoc_data = data
    end
  end

  def short_name
    name && name.sub(/@#{Ejabberd::DEFAULT_ROOMS_VHOST}\z/, '')
  end

  def short_name=(value)
    if value
      if value.include?('@')
        self.name = value
      else
        self.name = "#{value}@#{Ejabberd::DEFAULT_ROOMS_VHOST}"
      end
    else
      self.name = value
    end
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
    name, host = self.name.try(:split, '@', 2)
    return unless name && host
    self.name = "#{name.nodeprep}@#{host.nameprep}"
  end

  private
  def copy_errors_to_short_name
    errors[:name].each do |error_message|
      errors.add(:short_name, error_message)
    end
  end
end
