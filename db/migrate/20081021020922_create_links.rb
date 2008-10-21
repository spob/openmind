class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :name, :limit => 30, :null => false
      t.string :url, :null => false
      t.references :link_set
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
