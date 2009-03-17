class SeedUser < ActiveRecord::Migration
  def self.up
    enterprise = Enterprise.find(:first)
    User.with_options :password => 'changeme', :password_confirmation => 'changeme',
    :salt => 'sodiumchrolide', :enterprise_id => enterprise.id,
    :activated_at => Time.now do |u|
      
      u.create!({ :email => 'admin@openmindsw.com', 
        :last_name => "Admin" })
      
      u.create!({ :email => 'prodmgr@openmindsw.com',         
        :last_name => "ProdMgr" })
      
      u.create!({ :email => 'voter@openmindsw.com', 
        :last_name => "Voter" })
      
      u.create!({ :email => 'readonly@openmindsw.com', 
        :last_name => "ReadOnly" })
      
      u.create!({ :email => 'allocmgr@openmindsw.com', 
        :last_name => "AllocMgr" })
      
      u.create!({ :email => 'all@openmindsw.com', 
        :last_name => "All" })
    end
    
    # Now set all users as activated
    User.update_all ['activated_at = ?', Time.now]
  end
  
  def self.down
    # I drop into SQL here because using the model is problematic...
    # rails will complain tha the model for the foreign keys doesn't exist
    # since they were dropped by backing out a later migration script
    execute("delete from users where email = 'admin@openmindsw.com'")
    execute("delete from users where email = 'prodmgr@openmindsw.com'")
    execute("delete from users where email = 'voter@openmindsw.com'")
    execute("delete from users where email = 'readonly@openmindsw.com'")
    execute("delete from users where email = 'all@openmindsw.com'")
  end
end
