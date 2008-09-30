module OpenIdAuthentication
  attr_reader :openid_result
  
protected
  def begin_openid_authentication(identity, return_url, options = {})
    return :missing if identity.nil? or identity.strip == ''
    
    sreg_valid = %W{nickname fullname email dob gender postcode country timezone language}
    
    sreg_optional = options[:optional] || []
    sreg_required = options[:required] || []
    
    if sreg_optional.size == 0 and sreg_required.size == 0
      sreg_optional = sreg_valid
    else
      (sreg_required + sreg_optional).each do |i|
        raise "Invalid option: `#{i}`. Must be one of: #{sreg_valid.join(', ')}" unless sreg_valid.index(i)
      end
    end
    
    openid_request = timeout_protection_from_identity_server { open_id_consumer.begin(identity) }

    return :timeout if response.nil?
    
    case openid_request.status
    when OpenID::FAILURE
      return :failed
    when OpenID::SUCCESS
      openid_request.add_extension_arg('sreg', 'optional', sreg_optional.join(',')) if sreg_optional.size > 0
      openid_request.add_extension_arg('sreg', 'required', sreg_required.join(',')) if sreg_required.size > 0

      url = openid_request.redirect_url(
        self.request.protocol + self.request.host_with_port + "/",
        openid_request.return_to(self.request.protocol + self.request.host_with_port + return_url)
      )

      redirect_to(url)

      return :success
    end
    
    return :unknown
  end
  
  def complete_openid_authentication
    openid_response = timeout_protection_from_identity_server { open_id_consumer.complete(params) }

    case openid_response.status
    when OpenID::CANCEL
      return :canceled
    when OpenID::FAILURE
      return :failed
    when OpenID::SUCCESS
      @openid_result = {
        :identity_url   => openid_response.identity_url,
        :info           => openid_response.extension_response('sreg')
      }
      return :success
    end

    return :unknown
  end
  
private
  def open_id_consumer
    OpenID::Consumer.new(session, OpenIdAuthentication::DbStore.new)
  end
  
  def timeout_protection_from_identity_server
    yield
  rescue Timeout::Error
    nil
  end
end
