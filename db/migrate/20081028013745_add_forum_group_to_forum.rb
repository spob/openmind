require "migration_helpers"

class AddForumGroupToForum < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :forums do |t|
      t.references :forum_group
    end
    
    add_foreign_key(:forums, :forum_group_id, :lookup_codes)
  end

  def self.down
    remove_foreign_key(:forums, :forum_group_id)
    
    change_table :forums do |t|
      t.remove :forum_group_id
    end
  end
end
