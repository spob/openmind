require "migration_helpers"

class AddEnterpriseId < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :enterprises do |t|
      t.references :enterprise_type, :null => true
    end
    
    add_foreign_key(:enterprises, :enterprise_type_id, :lookup_codes)
  end

  def self.down
    remove_foreign_key(:enterprises, :enterprise_type_id)
    
    change_table :enterprises do |t|
      t.remove :enterprise_type_id
    end
  end
end
