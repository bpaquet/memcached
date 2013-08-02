
def spawn_memcached options
  pid = spawn("#{MEMCACHED_COMMAND} #{MEMCACHED_VERBOSITY} #{options} >> #{MEMCACHED_LOG} 2>&1")
  raise "Unable to start memcached with options #{options}" if Process.waitpid(pid, Process::WNOHANG)
  pid
end

unless defined? UNIX_SOCKET_NAME
  HERE = File.dirname(__FILE__)
  UNIX_SOCKET_NAME = File.join(ENV['TMPDIR']||'/tmp','memcached')

  # Kill memcached
  system("killall -9 memcached")

  # Start memcached
  MEMCACHED_VERBOSITY = (ENV['DEBUG'] ? "-vv" : "")
  MEMCACHED_LOG = "/tmp/memcached.log"
  MEMCACHED_COMMAND = ENV['MEMCACHED_COMMAND'] || 'memcached'

  system ">#{MEMCACHED_LOG}"

  # TCP memcached
  (43042..43046).each do |port|
    spawn_memcached "-U 0 -p #{port}"
  end
  # UDP memcached
  (43052..43053).each do |port|
    spawn_memcached "-U #{port} -p 0 "
  end
  # Domain socket memcached
  (0..1).each do |i|
    spawn_memcached " -M -s #{UNIX_SOCKET_NAME}#{i}"
  end
end
