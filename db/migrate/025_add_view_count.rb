class AddViewCount < ActiveRecord::Migration
  def self.up
    add_column(:ideas, :view_count, :integer, :null => false, :default => 0)
  end

  def self.down
    remove_column :ideas, :view_count
  end
end
