namespace :unicorn do
  PIDFILE = 'tmp/pids/unicorn.pid'

  task :stop do
    print 'Stopping unicorn server...'
    if File.exists?(PIDFILE)
      Process.kill('TERM', File.read(PIDFILE).to_i)
      catch(:done) do
        10.times do
          if File.exists?(PIDFILE)
            print '.'
            sleep 1
          else
            puts ' OK'
            throw :done
          end
        end
        puts ' Failed'
      end
    else
      puts ' Not running (pidfile not present)'
    end
  end

  task :start do
    print 'Starting unicorn server... '
    if File.exists?(PIDFILE)
      puts 'Already running (pidfile present)'
    else
      puts 'OK' if system('bundle exec unicorn_rails -E development -c config/unicorn.rb -D')
    end
  end

  task :restart => [:stop, :start]
end
