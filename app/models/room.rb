class Room < Contract
  def backup!
    self.adhoc_data = Ejabberd.new.room(name).info
  end

  def short_name
    name.sub(/@#{Ejabberd::DEFAULT_ROOMS_VHOST}\z/, '')
  end

  def short_name=
  end

  def occupants_number
    @occupants_number ||= Ejabberd.new.room(name).occupants_number
  end

  attr_reader :last_message_at

  def deactivate(server_destroy = true)
    backup!
    self.active = false
    self.deactivated_at = Time.now
    Ejabberd.new.room(name).destroy if server_destroy
    self
  end
end
