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
end
