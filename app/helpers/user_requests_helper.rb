module UserRequestsHelper
  def enterprise_action user_request
    if user_request.enterprise.nil?
      "Create enterprise '#{user_request.enterprise_name}'"
    else
      "Assign to '#{user_request.enterprise.name}'"
    end
  end
  
  def show_user_link user_request
    user = User.find_by_email(user_request.email) if user_request.status == UserRequest.approved
    if user.nil?
      h(user_request.email)
    else
      link_to h(user_request.email), :controller => 'users', :action => 'show', :id => user.id
    end    
  end
end
