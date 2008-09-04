class AddCachedTags < ActiveRecord::Migration
  def self.up      
    add_column :ideas, :cached_tag_list, :string
  end

  def self.down
    remove_column :ideas, :cached_tag_list
  end
end
