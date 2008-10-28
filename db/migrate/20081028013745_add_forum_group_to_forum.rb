class AddForumGroupToForum < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.references :forum_group
    end
  end

  def self.down
    change_table :forums do |t|
      t.remove :forum_group_id
    end
  end
end
