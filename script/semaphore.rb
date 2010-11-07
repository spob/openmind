# script/task_server_control.rb
#!/usr/bin/env ruby
#


options = {}

lock_file = File.dirname(__FILE__) + '/../tmp/lock.txt'
timeout = 30

ARGV.each do|a|
p = a.split('=').first
v = a.split('=').last
if p == "--timeout"
  timeout = v.to_i
elsif p == "--lockfile"
  lock_file = v
end

end

puts "Running at #{Time.now.zone}"
puts "Lock file #{lock_file}"
if File.exists?(lock_file)
puts "Semaphore file...sleeping for #{timeout} seconds"
sleep(timeout)
puts "Sleeping is done"
else
#  create the semaphore file
File.open(lock_file, 'w') {|f| f.write("Locked at #{Time.now.zone}") }
end