class PopulateMediatorRole < ActiveRecord::Migration
  def self.up
    Role.create(:title => "mediator", 
      :description => "Forum Mediator",
      :default_role => false)
    
    assign_user 'all@openmindsw.com', "mediator"
  end

  def self.down
    for role in Role.find(:all, :conditions => ['title = ?', 'mediator'])
      role.destroy
    end
  end
  
  private
  
  def self.assign_user(user_name, role_names)
    user = User.find_by_email(user_name)
    # throw "User not found: '#{user_name}'" if user.nil?
    return if user.nil?
    roles = Role.find :all, :conditions => { :title => role_names }
    user.roles << roles
  end
end
