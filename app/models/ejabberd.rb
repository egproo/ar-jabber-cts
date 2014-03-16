require 'xmlrpc/client'
require 'shellwords'

class Ejabberd
  DEFAULT_VHOST = 'syriatalk.biz'
  DEFAULT_ROOMS_VHOST = "conference.#{DEFAULT_VHOST}"

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
      @ej.ctl('destroy_room', @name, @host, DEFAULT_VHOST)
    end

    def create(owner = nil)
      @ej.ctl('create_room', @name, @host, DEFAULT_VHOST) if @host.include?(DEFAULT_VHOST)
      @ej.ctl('set_room_affiliation', @name, @host, owner, 'owner') if owner
    end
  end

  def room(name, host = nil)
    unless host
      name, host = name.split('@', 2)
      host = DEFAULT_ROOMS_VHOST unless host
    end
    Room.new(name, host, self)
  end

  def room_names(host = DEFAULT_ROOMS_VHOST)
    rpc_server.call(:muc_list,
                    host: host).map { |room| "#{room['room']}@#{room['host']}" }
  end

  def ctl(command, *args)
    cmdline = "#{command.shellescape} #{args.shelljoin}"
    Rails.logger.debug("CTL IN : #{cmdline}")
    `ssh #@server sudo /opt/ejabberd/sbin/ejabberdctl #{cmdline}`.tap { |output|
      output.each_line do |line|
        Rails.logger.debug("CTL OUT: #{line.chomp}")
      end
    }
  end

  def rpc_server
    @rpc_server ||= XMLRPC::Client.new_from_hash(
      host: 'de2.dget.cc',
      port: 4560,
      timeout: 30,
      path: '/',
    ).tap do |rpc_server|
      rpc_server.http_header_extra = { 'Content-Type' => 'text/xml' }
    end
  end

  OWL = 10

  def build_transactions
    (server_rooms = room_names).map do |room_name|
      real_room_name = room_name
      node, host = room_name.split('@', 2)
      room_name = "#{node.nodeprep}@#{host.nameprep}"

      tracked_rooms = ::Room.preload(:last_payment).where(name: room_name).all
      if tracked_rooms.present?
        if tracked_room = tracked_rooms.find(&:active)
          effective_to = tracked_room.last_payment.effective_to
          if effective_to < OWL.days.ago
            [[:destroy, room_name, "paid until #{effective_to.to_date}", tracked_room]]
          end
        else
          tracked_rooms.map do |tr|
            [:destroy, room_name, "contract with #{tr.buyer.name} deleted", tr]
          end
        end
      else
        [[:destroy, real_room_name, "not tracked"]]
      end
    end.compact.flatten(1) +
      ::Room.active.preload(:last_payment).where(['name not in (?)', server_rooms]).to_a.select do |r|
        r.last_payment.effective_to >= Time.now
      end.map { |r| [:create, r.name, 'new room', r] }
  end

  def apply_transactions(ts)
    ts.each do |action, name, reason, object|
      if action == :destroy
        if object
          object.deactivate.save!
        else
          room(name).destroy
        end
      elsif action == :create
        room(name).create(object.buyer.jid)
      end
    end
  end
end
