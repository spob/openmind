namespace :db do
  desc "Populate the database with seed data"
  task :seed => [:seed_enterprises, :seed_users, :seed_roles]

  desc "Seed the database with enterprises"
  task :seed_enterprises => :environment do
    @company_name = "Main Company"
    Enterprise.create(:name => @company_name)
  end

  desc "Seed the database with users"
  task :seed_users => :environment do
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

  desc "Seed the database with user roles"
  task :seed_roles => :environment do
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

  def assign_user(user_name, role_names)
    user = User.find_by_email(user_name)
    throw "User not found: '#{user_name}'" if user.nil?
    roles = Role.find :all, :conditions => { :title => role_names }
    user.roles << roles
  end
end