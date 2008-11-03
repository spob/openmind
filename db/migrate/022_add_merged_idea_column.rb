require "migration_helpers"

class AddMergedIdeaColumn < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_column(:ideas, :merged_to_idea_id, :integer, :null => true)
    
    add_foreign_key(:ideas, :merged_to_idea_id, :ideas)
  end

  def self.down
    remove_column :ideas, :merged_to_idea_id
  end
end
