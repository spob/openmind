class CreateAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :announcements, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :headline,  :string, :limit => 80, :null => false
      t.column :description,  :string, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :announcements
  end
end
