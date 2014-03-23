worker_processes 3
preload_app true
timeout 30
listen File.expand_path('tmp/sockets/unicorn.sock'), :backlog => 2048

before_fork do |server, worker|
  old_pid = File.expand_path('tmp/pids/unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill(:QUIT, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
