require "net/smtp"
require "net/pop"
# If smtp or pop is already loaded, remove all constants.
module Net
  if defined?(SMTP)
    SMTP.class_eval do remove_const(:Revision) end
    [:SMTP, :SMTPSession].each do |c|
      remove_const(c) if constants.include?(c.to_s)
    end
  end
  if defined?(POP)
    POP.class_eval do remove_const(:Revision) end
    [:POP, :POPSession, :POP3Session, :APOPSession].each do |c|
      remove_const(c) if constants.include?(c.to_s)
    end
  end
end

load File.dirname(__FILE__) + "/net/smtp.rb"
load File.dirname(__FILE__) + "/net/pop.rb"

Net::SMTP.class_eval do 
  def quit # gmail smtp server disconnects as soon as get quit message.
    begin
      getok('QUIT')
    rescue EOFError
    end
  end
end

