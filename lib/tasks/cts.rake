namespace :cts do
  task :remove_unused_rooms => :environment do
    ej = Ejabberd.new
    ej.room_names('syriatalk.biz').each_line do |name|
      unless Room.exists?(name: name.strip, active: true)
        puts "Destroy room #{name}"
      end
    end
  end
end
