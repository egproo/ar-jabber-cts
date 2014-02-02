class EjabberdController < ApplicationController
  OWL = 5

  def sync
    server_rooms = Ejabberd.new.room_names('syriatalk.biz').split
    @transactions = server_rooms.map do |room_name|
      tracked_rooms = Room.find_all_by_name(room_name)
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
        "#{room_name} destroy (not tracked)"
      end
    end.compact +
      Room.active.all(conditions: ['name not in (?)', server_rooms], include: :last_payment).select do |r|
        r.last_payment.effective_to >= OWL.days.ago
      end.map { |r| ["#{r.name} create", r] }
  end
end
