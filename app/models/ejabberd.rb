require 'xmlrpc/client'
require 'logger'

class Ejabberd
  config_file_path = Rails.root.join('config/rpc.yml')
  CONFIG = { 
      auth_code: nil,
      port: 4560,
      host: 'localhost',
    }.merge((YAML.load_file(config_file_path) rescue {})).freeze
  # Ensure the configuration file is written completely
  File.write(config_file_path, CONFIG.to_yaml)

  DEFAULT_VHOST = JabberCTS::CONFIG[:default_vhost]
  DEFAULT_ROOMS_VHOST = JabberCTS::CONFIG[:default_rooms_vhost]

  class Room
    def initialize(name, host, ej)
      @name, @host, @ej = name, host, ej
    end

    def info
      @ej.rpc(:muc_info,
              room: @name,
              host: @host)
    end

    def destroy(reason = nil)
      @ej.rpc(:muc_destroy,
              room: @name,
              host: @host,
              reason: reason || '')
    end

    def create(owner = nil)
      @ej.rpc(:muc_create,
              room: @name,
              host: @host,
              vhost: DEFAULT_VHOST,
              creator: owner || JabberCTS::CONFIG[:default_room_admin])
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
    rpc(:muc_list,
        host: host).map { |room| "#{room['room']}@#{room['host']}" }
  end

  def rooms(host = DEFAULT_ROOMS_VHOST)
    rpc(:muc_list,
        host: host)
  end

  def rpc_server
    @rpc_server ||= XMLRPC::Client.new_from_hash(
      self.class::CONFIG.merge(
        timeout: 30,
        path: '/',
      )
    ).tap do |rpc_server|
      rpc_server.http_header_extra = { 'Content-Type' => 'text/xml' }
    end
  end

  def rpc(name, arg)
    if CONFIG[:auth_code].blank?
      {}
    else
      self.class.logger.debug("RPC OUT: #{name}(#{arg.inspect})")
      arg = { auth_code: self.class::CONFIG[:auth_code] }.merge(arg) if Hash === arg
      rpc_server.call(name, arg).tap { |v| self.class.logger.debug("RPC IN: #{name}: #{v.inspect}") }
    end
  end

  def self.logger
    @logger ||= Logger.new(Rails.root.join('log/rpc.log')).tap { |logger| logger.level = Logger::DEBUG }
  end

  OWL = 10

  def announce(subject, body)
    rpc(:announce_send,
        vhost: DEFAULT_VHOST,
        subject: subject,
        body: body)
  end

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
            [:destroy, room_name, "contract with #{tr.buyer.name} disabled", tr]
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
          object.deactivate(deactivated_by: 'sync').save!
        else
          room(name).destroy
        end
      elsif action == :create
        room(name).create(object.buyer.jid)
      end
    end
  end
end
