require "migration_helpers"

class CreateEnterpriseTypeForums < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :enterprise_types_forums, :id => false  do |t|
      t.references :forum, :null => false
      t.references :enterprise_type, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:enterprise_types_forums, :forum_id, :forums)
    add_foreign_key(:enterprise_types_forums, :enterprise_type_id, :lookup_codes)
    
    add_index :enterprise_types_forums, [:forum_id, :enterprise_type_id], 
      :unique => true, :name => ':enterprise_types_forums_u1'
  end

  def self.down
    drop_table :enterprise_types_forums
  end
end
