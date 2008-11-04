require "migration_helpers"

class CreatePollEnterpriseTypesAndGroups < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :enterprise_types_polls, :id => false  do |t|
      t.references :poll, :null => false
      t.references :enterprise_type, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:enterprise_types_polls, :poll_id, :polls)
    add_foreign_key(:enterprise_types_polls, :enterprise_type_id, :lookup_codes)
    
    add_index :enterprise_types_polls, [:poll_id, :enterprise_type_id], 
      :unique => true, :name => ':enterprise_types_polls_u1'
    
    create_table :groups_polls, :id => false  do |t|
      t.references :poll, :null => false
      t.references :group, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:groups_polls, :poll_id, :polls)
    add_foreign_key(:groups_polls, :group_id, :groups)
    
    add_index :groups_polls, [:poll_id, :group_id], 
      :unique => true, :name => ':groups_polls_u1'
  end

  def self.down    
    remove_foreign_key(:enterprise_types_polls, :poll_id)
    remove_foreign_key(:enterprise_types_polls, :enterprise_type_id)
    
    drop_table :enterprise_types_polls
    drop_table :groups_polls
  end
end
