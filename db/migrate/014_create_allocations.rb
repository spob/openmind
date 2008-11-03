require "migration_helpers"

class CreateAllocations < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up 
    create_table :allocations, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :quantity, :integer, :default => 0, :null => false 
      t.column :comments, :string, :limit => 255
      t.references :user
      t.references :enterprise
      t.timestamps
      t.column :lock_version, :integer, :default => 0 
      t.column :allocation_type,  :string, :limit => 30, :null => false
    end
    
    add_foreign_key(:allocations, :user_id, :users)
    add_foreign_key(:allocations, :enterprise_id, :enterprises)
  end

  def self.down
    drop_table :allocations
  end

end
