require "migration_helpers"

class CreateWatches < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :watches, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8', :id => false  do |t|
      t.references :user, :null => false
      t.references :idea, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:watches, :user_id, :users)
    add_foreign_key(:watches, :idea_id, :ideas)
    
    add_index :watches, [:user_id, :idea_id], :unique => true
  end

  def self.down
    remove_foreign_key(:watches, :user_id)
    remove_foreign_key(:watches, :idea_id)
    
    drop_table :watches
  end
end
