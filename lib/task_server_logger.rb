class TaskServerLogger < Logger
  include Singleton
  
  def initialize
    puts "Writing to logfile: #{File.expand_path(File.dirname(__FILE__) + '/../log/task_server.log')}"
    logfile = File.open(File.dirname(__FILE__) + '/../log/task_server.log', 'a') 
    logfile.sync = true
    super(logfile)
  end
  
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
end 
