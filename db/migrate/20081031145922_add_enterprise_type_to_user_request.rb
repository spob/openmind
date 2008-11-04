require "migration_helpers"

class AddEnterpriseTypeToUserRequest < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :user_requests do |t|
      t.references :enterprise_type, :null => true
    end
    
    add_foreign_key(:user_requests, :enterprise_type_id, :lookup_codes)
  end

  def self.down
    change_table :user_requests do |t|
      t.remove :enterprise_type_id
    end
  end
end
