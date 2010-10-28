class AddDeltaToEnterprise < ActiveRecord::Migration
  def self.up
    add_column :enterprises, :delta, :boolean, :default => true, :null => false
    add_column :ideas, :delta, :boolean, :default => true, :null => false
    add_column :topics, :delta, :boolean, :default => true, :null => false
    add_column :comments, :delta, :boolean, :default => true, :null => false
  end
  
  def self.down
    change_table :comments do |t|
      t.remove :delta
    end
    change_table :topics do |t|
      t.remove :delta
    end
    change_table :ideas do |t|
      t.remove :delta
    end
    change_table :enterprises do |t|
      t.remove :delta
    end
  end
end
