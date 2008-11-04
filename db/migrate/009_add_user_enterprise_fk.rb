require "migration_helpers"

class AddUserEnterpriseFk < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :users do |t|
      t.references :enterprise, :null => true
    end
    
    User.reset_column_information
    enterprise = Enterprise.find(:first)
    
    User.find(:all).each do |u|
      enterprise.users << u
      enterprise.save
    end

    change_column(:users, :enterprise_id, :integer, :null => false)
    
    add_foreign_key(:users, :enterprise_id, :enterprises)
  end

  def self.down
    remove_foreign_key(:users, :enterprise_id)
    
    remove_column :users, :enterprise_id
  end
end
