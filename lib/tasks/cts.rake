namespace :cts do
  namespace :rooms do
    task :sync => :environment do
      ej = Ejabberd.new
      print "Building transactions... " if $stdout.tty?
      ts = ej.build_transactions
      puts ts.size if $stdout.tty?
      puts ts.map { |t| t.join(' ') } if ts.any? || $stdout.tty?
      print "Applying transactions... " if $stdout.tty?
      ej.apply_transactions ts
      puts 'OK' if $stdout.tty?
    end
  end

  namespace :db do
    task :obfuscate => :environment do
      abort 'Running obfuscate in production will ruin your database' if Rails.env.production?

      random_string = ->(low, high, range = 'a'..'z') { range.to_a.shuffle[0, low + rand(high - low + 1)].join }

      print 'Obfuscating rooms'
      Room.all.each do |r|
        r.name = "#{random_string[3, 15]}@#{Ejabberd::DEFAULT_ROOMS_VHOST}"
        r.adhoc_data = nil
        r.save!
        print '.'
      end
      puts

      print 'Obfuscating users'
      User.all.each do |u|
        u.jid = "#{random_string[3, 10]}@#{rand > 0.9 ? Ejabberd::DEFAULT_VHOST : 'example.com'}"
        u.phone = rand > 0.7 ? random_string[8, 15, '0'..'9'] : nil
        u.save!
        print '.'
      end
      puts

      rooms = Room.all
      print 'Obfuscating announcements'
      Announcement.all.each do |a|
        a.adhoc_data = "Lorem ipsum dolor sit amet, #{rand > 0.1 ? rooms.sample.name : 'consectetuer adipiscing elit'}"
        a.name = ''
        a.save!
        print '.'
      end
      puts

      superuser = User.where(role: User::ROLE_ADMIN).first
      superuser.password = 'secret'
      superuser.save!

      puts "Login as: #{superuser.jid} / secret"

      Audited::Adapters::ActiveRecord::Audit.delete_all
    end
  end
end
