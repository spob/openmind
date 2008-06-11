class AddUserEnterpriseFk < ActiveRecord::Migration
  def self.up
    add_column(:users, :enterprise_id, :integer, :null => true)
    
    User.reset_column_information
    enterprise = Enterprise.find(:first)
    
    User.find(:all).each do |u|
      enterprise.users << u
    end

    enterprise.save
    change_column(:users, :enterprise_id, :integer, :null => false)
  end

  def self.down
    remove_column :users, :enterprise_id
  end
end
