class AddMergedIdeaColumn < ActiveRecord::Migration
  def self.up
    add_column(:ideas, :merged_to_idea_id, :integer, :null => true)
  end

  def self.down
    remove_column :ideas, :merged_to_idea_id
  end
end
