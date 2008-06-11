class SeedUser < ActiveRecord::Migration
  def self.up
    enterprise = Enterprise.find(:first)
    User.with_options :password => 'changeme', :password_confirmation => 'changeme',
      :salt => 'sodiumchrolide', :enterprise_id => enterprise.id,
      :activated_at => Time.now do |u|
      
      u.create!({ :email => 'admin@openmind.org', 
          :last_name => "Admin" })
      
      u.create!({ :email => 'prodmgr@openmind.org',         
          :last_name => "ProdMgr" })
      
      u.create!({ :email => 'voter@openmind.org', 
          :last_name => "Voter" })
      
      u.create!({ :email => 'readonly@openmind.org', 
          :last_name => "ReadOnly" })
      
      u.create!({ :email => 'allocmgr@openmind.org', 
          :last_name => "AllocMgr" })
      
      u.create!({ :email => 'all@openmind.org', 
          :last_name => "All" })
    end
    
    # Now set all users as activated
    User.update_all ['activated_at = ?', Time.now]
  end

  def self.down
    # I drop into SQL here because using the model is problematic...
    # rails will complain tha the model for the foreign keys doesn't exist
    # since they were dropped by backing out a later migration script
    execute("delete from users where email = 'admin@openmind.org'")
    execute("delete from users where email = 'prodmgr@openmind.org'")
    execute("delete from users where email = 'voter@openmind.org'")
    execute("delete from users where email = 'readonly@openmind.org'")
    execute("delete from users where email = 'all@openmind.org'")
  end
end
