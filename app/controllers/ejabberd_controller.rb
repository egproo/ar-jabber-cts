class EjabberdController < ApplicationController
  def sync
    @transactions = Ejabberd.new.room_names('syriatalk.biz').split.map do |room_name|
      tracked_rooms = Room.find_all_by_name(room_name)
      if tracked_rooms.present?
        if tracked_room = tracked_rooms.find(&:active)
          effective_to = tracked_room.last_payment.effective_to
          if effective_to < 5.days.ago
            ["#{room_name} destroy (paid until #{effective_to.to_date})", tracked_room]
          end
        else
          "#{room_name} destroy (contract deleted)"
        end
      else
        "#{room_name} destroy (not tracked)"
      end
    end.compact
  end
end
