module UserRequestsHelper
  def enterprise_action user_request
    if user_request.enterprise.nil?
      "Create enterprise '#{user_request.enterprise_name}'"
    else
      "Assign to '#{user_request.enterprise.name}'"
    end
  end
end
