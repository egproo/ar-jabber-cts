namespace :cts do
  namespace :rooms do
    task :sync => :environment do
      ej = Ejabberd.new
      existing_rooms = ej.room_names.split.map { |room|
        room.force_encoding('utf-8')
        name, host = room.split('@', 2)
        "#{name.nodeprep}@#{host.nameprep}".force_encoding('utf-8')
      }
      tracked_rooms = Room.active.all(include: :last_payment).select { |room|
        room.last_payment.effective_to >= 5.days.ago
      }.map(&:name)

      destroy_rooms = existing_rooms - tracked_rooms
      create_rooms = tracked_rooms - existing_rooms

      destroy_rooms.each do |r|
        puts "Destroy room #{r}"
        #puts ej.room(r).destroy
      end

      create_rooms.each do |r|
        puts "Create room #{r}"
        #puts ej.room(r).create(Room.active.find_by_name(r).buyer.jid)
      end
    end
  end
end
