class SeedRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users 
  end
  class User < ActiveRecord::Base
    belongs_to :enterprise
    has_and_belongs_to_many :roles  
  end
  
  def self.up
    Role.create(:title => "sysadmin", 
    :description => "System Admininistrator",
    :default_role => false)
    Role.create(:title => "prodmgr", 
    :description => "Product Manager",
    :default_role => false)
    Role.create(:title => "voter", 
    :description => "Voter",
    :default_role => true)
    Role.create(:title => "allocmgr", 
    :description => "Allocations Manager",
    :default_role => false)
    
    assign_user 'admin@openmindsw.com', "sysadmin"
    assign_user 'prodmgr@openmindsw.com', "prodmgr"
    assign_user 'voter@openmindsw.com', "voter"
    assign_user 'allocmgr@openmindsw.com', "allocmgr"
    assign_user 'all@openmindsw.com', [ "voter", "sysadmin", "prodmgr", "allocmgr"  ]
  end
  
  def self.down
    for role in Role.find(:all)
      role.destroy
    end
  end
  
  private
  
  def self.assign_user(user_name, role_names)
    user = User.find_by_email(user_name)
    throw "User not found: '#{user_name}'" if user.nil?
    roles = Role.find :all, :conditions => { :title => role_names }
    user.roles << roles
  end
end