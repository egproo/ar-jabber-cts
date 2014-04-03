namespace :cts do
  namespace :rooms do
    task :sync => :environment do
      ej = Ejabberd.new
      print "Building transactions... "
      ts = ej.build_transactions
      puts ts.size
      puts ts.map { |t| t.join(' ') }
      print "Applying transactions... "
      ej.apply_transactions ts
      puts 'OK'
    end
  end
end
