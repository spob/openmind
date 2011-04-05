class AddSortToStory < ActiveRecord::Migration
  def self.up
    change_table :stories do |t|
      t.integer :sort, :null => true
    end
  end

  def self.down
    change_table :stories do |t|
      t.remove :sort
    end
  end
end
