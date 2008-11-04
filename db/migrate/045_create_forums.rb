class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :string, :limit => 150, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_index :forums, :name, :unique => true
  end

  def self.down
    drop_table :forums
  end
end
