class Room < Contract
  def backup!
    affiliations = {}
    (Ejabberd.new.room(name).affiliations || '').each_line do |line|
      node, server, affiliation, reason = line.split(nil, 4)
      node, server, affiliation = nil, node, server unless affiliation

      # FIXME: security issue (writable - major): multi-line reason may create fake affiliation entry
      next unless %w(owner member outcast admin).include?(affiliation)

      (affiliations[affiliation.to_sym] ||= []) << { node: node, server: server }
    end
    self.adhoc_data = { affiliations: affiliations }
  end

  def short_name
    name.sub(/@#{Ejabberd::DEFAULT_ROOMS_VHOST}\z/, '')
  end

  def short_name=
  end

  def occupants_number
    @occupants_number ||= Ejabberd.new.room(name).occupants_number
  end

  def deactivate(server_destroy = true)
    backup!
    self.active = false
    self.deactivated_at = Time.now
    Ejabberd.new.room(name).destroy if server_destroy
    self
  end
end
