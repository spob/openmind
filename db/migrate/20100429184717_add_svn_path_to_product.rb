class AddSvnPathToProduct < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.string :svn_path, :null => true
    end
  end

  def self.down
    change_table :products do |t|
      t.remove :svn_path
    end
  end
end
