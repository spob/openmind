require "migration_helpers"

class CreateVotes < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :votes do |t|
      t.references :user, :null => false
      t.references :allocation, :null => false
      t.references :idea, :null => false
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
      
    add_foreign_key(:votes, :user_id, :users)
    add_foreign_key(:votes, :allocation_id, :allocations)
    add_foreign_key(:votes, :idea_id, :ideas)
  end

  def self.down
    remove_foreign_key(:votes, :user_id)
    remove_foreign_key(:votes, :allocation_id)
    remove_foreign_key(:votes, :idea_id)
    
    drop_table :votes
  end
end
