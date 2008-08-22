class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements do |t|
      t.column :headline,  :string, :limit => 80, :null => false, :option => 'charset utf8'
      t.column :description,  :string, :null => false, :option => 'charset utf8'
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :announcements
  end
end
