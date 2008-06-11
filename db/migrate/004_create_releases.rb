class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.column :version,  :string, :limit => 20, :null => false
      t.column :product_id,  :integer, :null => false
      t.column :release_status_id,  :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0
    end
    
    add_index :releases, :version, :unique => true
  end

  def self.down
    drop_table :releases
  end
end
