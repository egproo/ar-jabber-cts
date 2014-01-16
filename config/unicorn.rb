worker_processes 3
preload_app true
timeout 30
listen File.expand_path('tmp/sockets/unicorn.sock'), :backlog => 2048
after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
