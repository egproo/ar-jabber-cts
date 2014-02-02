class Room < Contract
  def backup!
    affiliations = {}
    (Ejabberd.new.room(name).affiliations || '').each_line do |line|
      node, server, affiliation = line.split
      node, server, affiliation = nil, node, server unless affiliation

      (affiliations[affiliation.to_sym] ||= []) << { node: node, server: server }
    end
    self.adhoc_data = { affiliations: affiliations }
  end

  def occupants_number
    Ejabberd.new.room(name).occupants_number
  end

  def deactivate(server_destroy = true)
    backup!
    self.active = false
    #Ejabberd.new.room(name).destroy if server_destroy
    self
  end
end
