require File.dirname(__FILE__) + '/test_helper.rb'

class TlsmailTest < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
  end
  
  def test_send_mail
    require "time"
    msgstr = <<END_OF_MESSAGE
From: Your Name <#{USER}@gmail.com>
To: Destination Address <#{USER}@gmail.com>
Subject: test message
Date: #{Time.now.rfc2822}

test message.
END_OF_MESSAGE
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start(SMTP_SERVER, SMTP_PORT, DOMAIN, USER, PASS, AUTH) do |smtp|
      smtp.send_message msgstr, "#{USER}@gmail.com", "#{USER}@gmail.com"
    end
  end
  
  def test_receive_mail
    Net::POP.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
    Net::POP.start(POP_SERVER, POP_PORT, USER, PASS) do |pop|
      p pop.mails[0].pop
    end
  end
end
