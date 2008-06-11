class AdditionalIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :enterprise_id, :unique => false
    add_index :ideas, :merged_to_idea_id, :unique => false
  end

  def self.down
    remove_index :users, :enterprise_id
    remove_index :ideas, :merged_to_idea_id
  end
end
