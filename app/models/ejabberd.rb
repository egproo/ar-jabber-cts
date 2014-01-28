class Ejabberd
  def initialize(server = 'de2')
    @server = server
  end

  class Room
    def initialize(name, host, ej)
      @name, @host, @ej = name, host, ej
    end

    def occupants_number
      text = @ej.ctl('get_room_occupants_number', @name, @host)
      text.include?('room_not_found') ? 'Room not found' : text
    end
  end

  def room(name, host = nil)
    unless host
      name, host = name.split('@', 2)
      host = 'conference.syriatalk.biz' unless host
    end
    Room.new(name, host, self)
  end

  def ctl(command, *args)
    `ssh #@server sudo /opt/ejabberd/sbin/ejabberdctl #{command} #{args.join(' ')}`
  end
end
