require "migration_helpers"

class CreateUserIdeaReads < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :user_idea_reads do |t|
      t.references :user, :null => false
      t.references :idea, :null => false
      t.column :last_read, :datetime, :null => false, :default => Time.zone.now
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
    
    add_foreign_key(:user_idea_reads, :user_id, :users)
    add_foreign_key(:user_idea_reads, :idea_id, :ideas)
    
    add_index :user_idea_reads, [:user_id, :idea_id], :unique => true
  end

  def self.down
    drop_table :user_idea_reads
  end
end
