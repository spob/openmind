class AddGroup < ActiveRecord::Migration
  def self.up
    create_table :groups, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8'  do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :string, :limit => 150, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_index :groups, :name, :unique => true
  end

  def self.down
    drop_table :groups
  end
end
