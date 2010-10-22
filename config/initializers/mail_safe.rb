if defined?(MailSafe::Config)
  MailSafe::Config.internal_address_definition = lambda { |address|
      address =~ /.*@sturim.org/i || address =~ /.*sturim@scribesoft.com/i
  }
	MailSafe::Config.replacement_address = 'bob@sturim.org'
end