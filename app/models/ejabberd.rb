require 'shellwords'
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
      text.include?('room_not_found') ? nil : text
    end

    def affiliations
      text = @ej.ctl('get_room_affiliations', @name, @host)
      text.include?('"The room does not exist."') ? nil : text
    end

    def destroy
      @ej.ctl('destroy_room', @name, @host, 'syriatalk.biz')
    end

    def create(owner = nil)
      @ej.ctl('create_room', @name, @host, 'syriatalk.biz') if @host.include?('syriatalk.biz')
      @ej.ctl('set_room_affiliation', @name, @host, owner, 'owner') if owner
    end
  end

  def room(name, host = nil)
    unless host
      name, host = name.split('@', 2)
      host = 'conference.syriatalk.biz' unless host
    end
    Room.new(name, host, self)
  end

  def room_names(host)
    ctl('muc_online_rooms', host)
  end

  def ctl(command, *args)
    Rails.logger.debug("CTL: #{command} #{args}")
    `ssh #@server sudo /opt/ejabberd/sbin/ejabberdctl #{command.shellescape} #{args.shelljoin}`.tap { |output|
      Rails.logger.debug output
    }
  end
end
