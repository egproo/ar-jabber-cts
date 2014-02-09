class EjabberdController < ApplicationController
  OWL = 10

  def sync
    server_rooms = Ejabberd.new.room_names.split
    @transactions = server_rooms.map do |room_name|
      real_room_name = room_name
      node, host = room_name.split('@', 2)
      room_name = "#{node.nodeprep}@#{host.nameprep}"

      tracked_rooms = Room.where(name: room_name).includes(:last_payment).all
      if tracked_rooms.present?
        if tracked_room = tracked_rooms.find(&:active)
          effective_to = tracked_room.last_payment.effective_to
          if effective_to < OWL.days.ago
            ["#{room_name} destroy (paid until #{effective_to.to_date})", tracked_room]
          end
        else
          "#{room_name} destroy (contract deleted)"
        end
      else
        "#{real_room_name} destroy (not tracked)"
      end
    end.compact +
      Room.active.all(conditions: ['name not in (?)', server_rooms], include: :last_payment).select do |r|
        r.last_payment.effective_to >= Time.now
      end.map { |r| ["#{r.name} create", r] }
  end
end
